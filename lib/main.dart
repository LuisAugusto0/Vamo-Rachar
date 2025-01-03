// import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vamorachar/database/sql_tables.dart';
import 'package:vamorachar/historico.dart';
import 'package:vamorachar/novo_rachamento.dart';
import 'database/database_helper.dart';
import 'database/sql_providers.dart';
import 'constants/colors.dart';
import 'tela_inicial.dart';
import 'cadastro.dart';
import 'login_inicial.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';  // Import sqflite_common_ffi
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dotenv
  await dotenv.load(fileName: ".env");

  print(dotenv.env);

  // Initialize sqflite FFI and database asynchronously
  await initializeDatabase();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      scaffoldBackgroundColor: const Color(verdePrimario),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: LoginInicial()
  ));



  final db = DatabaseHelper();
  db.assertAllTablesExists();


  // LoginProvider loginProvider = LoginProvider(db);
  // final res =  await loginProvider.getById(1);
  // debugPrint(res.toString());
  //
  // ContributionProvider contributionProvider = ContributionProvider(db);
  // final res2 = await contributionProvider.getByIdList([1,2,3,4], limit: 10);
  // debugPrint(res2.toString());

  testProviders();
}


void testProviders() async {
  LoginProvider loginProvider = LoginProvider(DatabaseHelper());

  loginProvider.insert(const LoginSql(name: "name", email: "email@email.com", password: "password1#"));
  LoginSql? query = await loginProvider.getLastAddedAutoIncrementId();
  debugPrint(query.toString());
  if (query == null) throw AssertionError('Result was expected to be added');

  int id = query.id!;
  LoginSql updateSql = LoginSql(name: "name2", email: "email2@email.com", password: "password2#");

  loginProvider.updateByAutoIncrementId(updateSql, id);
  query = await loginProvider.getByAutoIncrementId(id);
  debugPrint('after update ${query.toString()}');

  loginProvider.removeByAutoIncrementId(id);
}




Future<void> initializeDatabase() async {
  WidgetsFlutterBinding.ensureInitialized();
  //initialize firebse
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initiated with success");
  } catch (e){
    print("An error ocurred in the firebase initialization: $e");
  }

  // Initialize the database based on the platform
  if (kIsWeb) {


  } else if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {


  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux) {

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

class TestScreen extends StatefulWidget {
  TestScreen({super.key});
  final DatabaseHelper db = DatabaseHelper();

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {

  @override
  Widget build(BuildContext context) {

    return const Text('Test Screen');
  }
}