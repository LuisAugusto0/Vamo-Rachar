// import 'dart:typed_data';

import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite FFI and database asynchronously
  await initializeDatabase();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      scaffoldBackgroundColor: const Color(verdePrimario),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: Text('test')//LoginInicial()
  ));



  final db = DatabaseHelper();
  db.assertAllTablesExists();
  //
  //
  // LoginProvider loginProvider = LoginProvider(db);
  // final res =  await loginProvider.getById(1);
  // debugPrint(res.toString());
  //
  // ContributionProvider contributionProvider = ContributionProvider(db);
  // final res2 = await contributionProvider.getByIdList([1,2,3,4], limit: 10);
  // debugPrint(res2.toString());

}


Future<void> initializeDatabase() async {
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