// database_helper.dart
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:vamorachar/login.dart';
import 'database_definitions.dart';
import 'sql_tables.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_helper.dart';


class DatabaseHelper extends FirebaseHelper {

  static const dbName = 'base';

  static const loginTable = LoginSql.table;
  static const userTable = UserSql.table;
  static const userPurchaseTable = UserPurchaseSql.table;
  static const purchaseTable = PurchaseSql.table;
  static const productTable = ProductSql.table;
  static const productUnitTable = ProductUnitSql.table;
  static const contributionTable = ContributionSql.table;


  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;
  // Ensures only one instance exists
  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();


  Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }




  Future<void> testDatabase(Database db) async {
    try {
      /* I cant find any specific operation to check if its corrupted or not
       * In the offchance that its corrupted, im assuming db.getVersion()
       * will throw an exception
       */
      await db.getVersion();

    } catch (e) {
      rethrow;

    }
  }

  Future<void> _onDatabaseOpen(Database db) async {
    try {
      // Allow foreign key constraints
      await db.execute("PRAGMA foreign_keys = ON;");

      testDatabase(db);

    } catch(e) {
      debugPrint('Database is not valid: $e');
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, '$dbName.db');
    debugPrint("data base path: $path");

    bool created = false;
    Database res;
    try {
      res = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          debugPrint("Preloading database");
          await createTables(db);
          created = true;

        },
        onOpen: (db) async {
          debugPrint("Database opened.");
          await _onDatabaseOpen(db);
        },
      );
    } catch (e) {
      debugPrint("Error during database initialization: $e");
      rethrow;
    }


    if (created) {
      await initLaunchData(res);
    }
    assertAllTableWrappers(res);

    return res;
  }



  // Assert table existance
  Future<bool> tableExists(String tableName) async {
    final db = await getDatabase();


    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );

    return result.isNotEmpty;
  }

  Future<void> assertAllTablesExists() async {
    List<String> tables = [userTable, purchaseTable, userPurchaseTable,
      productTable, productUnitTable, contributionTable];

    for (final table in tables) {
      assert(await tableExists(table));
    }
  }


  // Assert if table classes are properly set
  Future<Map<String, dynamic>?> getFirstTableResult(Database db, String tableName) async {
    final List<Map<String, dynamic>> result = await db.query(
        tableName,
        limit: 1
    );

    return result.isEmpty ? null : result.first;
  }

  Future<void> assertTableWrapper(Database db, String tableName, Function(Map<String, dynamic>) fromMap) async {
    final res = await getFirstTableResult(db, tableName);
    if (res == null) {
      debugPrint("Could not assert $tableName as it is empty");
    } else {
      fromMap(res); // Executes the provided function to process the result
    }
  }

  Future<void> assertAllTableWrappers(Database db) async {
    await assertTableWrapper(db, loginTable, LoginSql.fromQueryMap);
    await assertTableWrapper(db, userTable, UserSql.fromQueryMap);
    await assertTableWrapper(db, userPurchaseTable, UserPurchaseSql.fromQueryMap);
    await assertTableWrapper(db, purchaseTable, PurchaseSql.fromQueryMap);
    await assertTableWrapper(db, productTable, ProductSql.fromQueryMap);
    await assertTableWrapper(db, productUnitTable, ProductUnitSql.fromQueryMap);
    await assertTableWrapper(db, contributionTable, ContributionSql.fromQueryMap);
  }


  // Firestore backup functions //

  Future<void> removeLocalDatabase() async {
    Database db = await getDatabase();
    await dropTables(db);
    await createTables(db);
    print("db removed");
  }

  Future<void> resetLocalDatabase() async {
    Database db = await getDatabase();
    await dropTables(db);
    await createTables(db);
    await initTestData(db);
    print("db reseted");
  }

  Future<String?> createFirestoreBackup() async {
    String? error;
    try {
      if (await isLoggedIn() == false) {
        throw Exception('No user is currently signed in.');
      }
      //organization in the firebase: uid/tableName/rows/id/values

      //Get uid from curent user (used for the root collection)
      final uid = getCurrentUserUID()!;
      final database = await getDatabase();
      // Get all table names from SQLite (used for the first level documents)
      final tableNames = await database.query(
        'sqlite_master',
        columns: ['name'],
        where: 'type = ?',
        whereArgs: ['table'],
      );

      for (final tableNameMap in tableNames) {
        final tableName = tableNameMap['name'] as String;

        if (tableName == 'android_metadata' || tableName == 'sqlite_sequence') {
          // Skip system tables
          continue;
        }

        // Get all rows from the table
        final rows = await database.query(tableName);

        if (rows.isEmpty) {
          continue; // Skip empty tables
        }

        // Reference to the Firestore document for the table
        final tableDocRef = FirebaseFirestore.instance.collection(uid).doc(tableName);
        // Delete old values if there is any
        tableDocRef.delete();

        // Write rows to Firestore using a batch (rows as the collection in the second level, and the ids on the third level and the values vinculated in the id on the fourth level)
        final batch = FirebaseFirestore.instance.batch();

        for (final row in rows) {
          final rowId = row['id']; // Assuming 'id' is the primary key
          if (rowId == null) {
            continue; // Skip rows without an 'id'
          }

          // Reference to the document for the row
          final rowDocRef = tableDocRef.collection('rows').doc(rowId.toString());

          // Add the set operation to the batch
          batch.set(rowDocRef, row);
        }

        // Commit the batch
        await batch.commit();
      }

      print('Firestore backup completed successfully.');
    } catch (e) {
      print('Error creating Firestore backup: $e');
      error = e.toString();
    }
    return error;
  }

  Future<String?> restoreFromFirestoreBackup() async {
    String? error;
    try {
      if (await isLoggedIn() == false) {
        throw Exception('No user is currently signed in.');
      }

      final uid = getCurrentUserUID()!;
      final database = await getDatabase();
      removeLocalDatabase();

      //get table Names
      final tableNames = await database.query(
        'sqlite_master',
        columns: ['name'],
        where: 'type = ?',
        whereArgs: ['table'],
      );

      //Foreach tableName, fill this table by the data value on the rows collection (copying the id's sequentially)
      for (final tableMap in tableNames) {
        final tableName = tableMap['name'] as String;
        final instancies = await FirebaseFirestore.instance.collection(uid).doc(tableName).collection('rows');

        //Start in the id=1 and end when there is no more id's
        int id = 1;
        var finalMap = await FirebaseFirestore.instance.collection(uid).doc(tableName).collection('rows').doc(id.toString()).get();
        while (finalMap.data() != null) {
          // Insert data into your local database
          database.insert(tableName, finalMap.data()!);

          id++;
          finalMap = await FirebaseFirestore.instance.collection(uid).doc(tableName).collection('rows').doc(id.toString()).get();
        }
      }


      // Get all table documents from Firestore
      final tableDocsSnapshot = await FirebaseFirestore.instance.collection(uid).get();


      // Start a transaction to ensure data integrity
      // await database.transaction((txn) async {
      print(tableDocsSnapshot.size);
        // Restore each table from Firestore
        for (final tableDoc in tableDocsSnapshot.docs) {
          //set the name of the table as the name of the document in firebase
          final tableName = tableDoc.id;

          // Get all rows from the table document's rows collection
          final rowsSnapshot = await tableDoc.reference.collection('rows').get();

          for (final rowDoc in rowsSnapshot.docs) {
            final rowData = rowDoc.data();
            database.insert(tableName, Map<String, dynamic>.from(rowData));
            print("Inserted ${Map<String, dynamic>.from(rowData)}");
          }
        }
      // });

      print('Restore from Firestore backup completed successfully.');
    } catch (e) {
      removeLocalDatabase();
      print('Error restoring Firestore backup: $e');
      error = e.toString();
    }
    return error;
  }

}









