// import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'tela_inicial.dart';
import 'Cadastro.dart';
import 'Login_inicial.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(verdePrimario),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginInicial(),
    )
  );
}