// import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vamorachar_telacadastro/historico.dart';
import 'package:vamorachar_telacadastro/novo_rachamento.dart';
import 'constants/colors.dart';
import 'tela_inicial.dart';
import 'cadastro.dart';
import 'login_inicial.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';  // Import sqflite_common_ffi
import 'package:sqflite/sqflite.dart';
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
    home: const LoginInicial(),
  ));
}


Future<void> initializeDatabase() async {
  // Initialize the database based on the platform
  if (kIsWeb) {
    // Handle web-specific logic if needed (sqflite isn't supported directly on web)
  } else if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    // Initialize database for Android or iOS
    // Use the normal sqflite setup for mobile
    databaseFactory = databaseFactory;  // This is actually for desktop
    // Do your normal sqflite database initialization here (e.g., openDatabase)
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux) {
    // Initialize for Desktop (using FFI)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
