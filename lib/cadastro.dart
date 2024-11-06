import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vamorachar_telacadastro/widgets/form_widgets.dart';
import 'package:vamorachar_telacadastro/widgets/validation_helpers.dart';
import 'package:vamorachar_telacadastro/constants/colors.dart';
import 'tela_inicial.dart';

import 'package:vamorachar_telacadastro/widgets/database_helper.dart';


class Cadastro extends StatelessWidget {
  const Cadastro({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MyHomePage(title: 'Tela de cadastro'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _obscureText = true; // Boolean para trocar visibilidade
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();
  final dbHelper = DatabaseHelper();

  Route _homeRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const Home(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, -1.0); // De cima para baixo
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<VoidCallback?> _submit() async{
    String? userError = validateUser(_userController);
    String? emailError = validateEmail(_emailController);
    String? passwordError = validatePassword(_passwordController);
    String? passwordConfirmationError = validatePasswordConfirmation(_passwordController, _passwordConfirmationController);

    print("Botão de registrar pressionado");
    if (emailError == null &&
        userError == null &&
        passwordError == null &&
        passwordConfirmationError == null) {
      print(_userController.value.text);
      print(_emailController.value.text);
      print(_passwordController.value.text);
      print(_passwordConfirmationController.value.text);
      dbHelper.createUser(_userController.text, _emailController.text, _passwordController.text);
      Navigator.of(context).push(_homeRoute());
    } else {
      print("Erro - os seguintes campos estão incorretos:");
      userError != null ? print(userError) : null;
      emailError != null ? print(emailError) : null;
      passwordError != null ? print(passwordError) : null;
      passwordConfirmationError != null
          ? print(passwordConfirmationError)
          : null;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return Scaffold(
      backgroundColor: const Color(verdePrimario),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              PreferredSize(
                preferredSize: const Size.fromHeight(200),
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        height: 200,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 50, right: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    form(
                        "Usuário", //Label do TextField
                        Icons.account_circle_outlined, //Ícone do TextField
                        TextInputType.text, //Tipo do Teclado
                        _userController, // Controlador do TextField
                        validateUser(_userController), // Verifica se há erro
                        (text) => setState(() => ()), // OnChanged
                        true // Enabled?
                        ),
                    form(
                        "E-mail", //Label do TextField
                        Icons.email_outlined, //Ícone do TextField
                        TextInputType.emailAddress, //Tipo do Teclado
                        _emailController, // Controlador do TextField
                        validateUser(_userController), // Verifica se há erro
                        (text) => setState(() => ()), // OnChanged
                        true // Enabled?
                        ),
                    passwordForm(
                        // hint, ico, controller, error, obscureText, toggleVisibility, onChanged, enabled
                        "Senha", //Lable do TextField
                        Icons.key_outlined, //Ícone do TextField
                        _passwordController, // Controlador do TextField
                        validatePassword(
                            _passwordController), // Verifica se há erro
                        _obscureText, // boolean para controlar visibilidade
                        _toggleVisibility,
                        (text) => setState(() => ()), // OnChanged
                        true // Enabled?
                        ),
                    passwordForm(
                        // hint, ico, controller, error, obscureText, toggleVisibility, onChanged, enabled
                        "Confirmar senha", //Lable do TextField
                        Icons.key_outlined, //Ícone do TextField
                        _passwordConfirmationController, // Controlador do TextField
                        validatePasswordConfirmation(_passwordController,
                            _passwordConfirmationController), // Verifica se há erro
                        _obscureText, // boolean para controlar visibilidade
                        _toggleVisibility,
                        (text) => setState(() => ()), // OnChanged
                        true // Enabled?
                        ),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Background color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20.0), // Rounded corners
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 12.0), // Padding inside the button
                      ),
                      child: const Text('Registrar',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
