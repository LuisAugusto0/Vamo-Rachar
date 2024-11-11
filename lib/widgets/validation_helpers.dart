// lib/widgets/validation_helpers.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vamorachar/database/database_helper.dart';
import 'package:vamorachar/database/sql_tables.dart';

// Variáveis globais e regex
final RegExp specialCharacters = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

String? validateUser(TextEditingController controller) {
  String value = controller.text;
  if (value.isEmpty) {
    return "Escreva um nome de usuário";
  }
  return null;
}

String? validateEmail(TextEditingController controller) {
  String value = controller.text;
  final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+.[a-zA-Z]+").hasMatch(value);
  if (value.isEmpty) {
    return "Escreva um email";
  } if (!emailValid){
    return "E-mail não é válido";
  }
  return null;
}

String? validatePassword(TextEditingController controller) {
  String value = controller.text;
  if (value.length < 6) {
    return "Mínimo 6 caracteres";
  } else if (!value.contains(specialCharacters)) {
    return "Necessita de pelo menos um caractere especial";
  }
  return null;
}

String? validateInteiro(TextEditingController controller) {
  String value = controller.text;
  if(int.tryParse(value) == null){
    return "Favor inserir apenas valores numéricos sem vírgula";
  }
  return null;
}

String? validadeDouble(TextEditingController controller) {
  String value = controller.text;
  if(double.tryParse(value) == null){
    return "Favor inserir apenas valores numéricos (Em caso de número quebrado, usar '.')";
  }
  return null;
}

String? validatePasswordConfirmation(TextEditingController passwordController,
    TextEditingController passwordConfirmationController) {
  String password = passwordController.text;
  String passwordConfirmation = passwordConfirmationController.text;
  if (password != passwordConfirmation) {
    return "As senhas não estão iguais";
  }
  return null;
}

String? validateOldPassword(TextEditingController oldPasswordController, TextEditingController currentPasswordController) {
  String oldPassword = oldPasswordController.text;
  String currentPassword = currentPasswordController.text;

  if (oldPassword != currentPassword) {
    return "Senha antiga incorreta";
  }
  return null;
}


String? validateLogin(TextEditingController passwordController, Map<String, Object?>? user){
  if(user == null){
    return "Usuário não encontrado";
  } else if (passwordController.text != user['senha']){
    return "A senha está incorreta";
  }
  return null;
}

// String? validateLogin(TextEditingController passwordController, LoginSql? login){
//   if(login == null){
//     return "Usuário não encontrado";
//   } else if (passwordController.text != login.password){
//     return "A senha está incorreta";
//   }
//   return null;
// }

// bool validateLogin(TextEditingController passwordController, LoginSql login) {
//   return (passwordController.text != login.password);
//
// }

