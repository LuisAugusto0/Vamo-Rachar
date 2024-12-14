// lib/widgets/avatar_widget.dart
import 'package:flutter/material.dart';
import 'package:vamorachar/constants/colors.dart';

Widget userAvatarCustom(String url) {
  return Stack(
    children: [
      CircleAvatar(
        backgroundColor: const Color(verdePrimario),
        radius: 100,
        child: ClipOval(
          child: Image.network(
            url,
            fit: BoxFit.cover,
            width: 200,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.account_circle,
                  size: 200, color: Color(verdeSecundario));
            },
          ),
        ),
      ),
      Positioned(
        bottom: 5,
        right: 10,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                width: 3,
                color: Colors.white,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(
                  50,
                ),
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(2, 4),
                  color: Colors.black.withOpacity(
                    0.3,
                  ),
                  blurRadius: 3,
                ),
              ]),
          child: const Padding(
            padding: EdgeInsets.all(2.0),
            child: Icon(Icons.edit_outlined, color: Color(verdePrimario)),
          ),
        ),
      ),
    ],
  );
}

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


