// lib/widgets/form_widgets.dart
import 'package:flutter/material.dart';
import 'package:vamorachar_telacadastro/constants/colors.dart'; // Importa as cores

// Widget de campo de formulário genérico
Widget form(
    String hint,
    IconData ico,
    TextInputType tip,
    TextEditingController controller,
    String? error,
    Function(String)? onChanged,
    bool enabled) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      keyboardType: tip,
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      style: TextStyle(
        fontSize: 15.0,
        color: enabled ? Colors.black : Colors.grey,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        prefixIcon: Icon(ico, color: const Color(verdePrimario)),
        hintStyle: const TextStyle(fontSize: 20.0, color: Colors.black54),
        labelText: hint,
        errorText: error,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(verdePrimario), width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
    ),
  );
}

Widget senhaOculta(
    String hint,
    IconData ico,
    TextInputType tip,
    TextEditingController controller,
    String? error,
    Function(String)? onChanged,
    bool enabled) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      keyboardType: tip,
      controller: controller,
      obscureText: true,
      onChanged: onChanged,
      enabled: enabled,
      style: TextStyle(
        fontSize: 15.0,
        color: enabled ? Colors.black : Colors.grey,
      ), // Cor condicional
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        prefixIcon: Icon(ico, color: const Color(verdePrimario)),
        hintStyle: const TextStyle(fontSize: 20.0, color: Colors.black54),
        labelText: hint,
        errorText: error,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(verdePrimario), width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
    ),
  );
}

// Widget específico para campos de senha
Widget passwordForm(
    String hint,
    IconData ico,
    TextEditingController controller,
    String? error,
    bool obscureText,
    Function toggleVisibility,
    Function(String)? onChanged,
    bool enabled) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      enabled: enabled,
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      style: const TextStyle(
          fontSize: 15.0, color: Colors.black), // Cor condicional),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        prefixIcon: Icon(ico, color: Colors.black),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.black),
          onPressed: () => toggleVisibility(),
        ),
        hintStyle: const TextStyle(fontSize: 20.0, color: Colors.black54),
        hintText: hint,
        errorText: error,
        // Borda quando o campo NÃO está focado
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),

        // Borda quando o campo está focado
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF15BA78), width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),

        // Borda quando há um erro
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),

        // Borda quando o campo está focado e tem erro
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12, width: 2.0),
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
    ),
  );
}
