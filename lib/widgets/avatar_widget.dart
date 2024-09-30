// lib/widgets/avatar_widget.dart
import 'package:flutter/material.dart';
import 'package:vamorachar_telacadastro/constants/colors.dart';

Widget userAvatar(String url) {
  return CircleAvatar(
    backgroundColor: const Color(verdePrimario),
    radius: 100,
    child: ClipOval(
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: 200,
        height: 200,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.account_circle, size: 200, color: Color(verdeSecundario));
        },
      ),
    ),
  );
}
