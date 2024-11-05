// lib/widgets/validation_helpers.dart
import 'package:flutter/material.dart';

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
  if (value.isEmpty) {
    return "Escreva um email";
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

String? validatePasswordConfirmation(TextEditingController passwordController,
    TextEditingController passwordConfirmationController) {
  String password = passwordController.text;
  String passwordConfirmation = passwordConfirmationController.text;
  if (password != passwordConfirmation) {
    return "As senhas não estão iguais";
  }
  return null;
}

String? validateOldPassword(TextEditingController passwordController,
    TextEditingController passwordConfirmationController) {
  String password = passwordController.text;
  String passwordConfirmation = passwordConfirmationController.text;
  if (password != passwordConfirmation) {
    return "Senha antiga incorreta";
  }
  return null;
}

String? validateLogin(TextEditingController passwordController, Map<String, Object?>? user){
  if(user == null){
    return "Usuário não encontrado";
  } else if (passwordController.text != user['senha']){
    return "A senha não está correta";
  }
  return null;
}
