import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vamorachar_telacadastro/constants/colors.dart';
import 'package:vamorachar_telacadastro/widgets/form_widgets.dart';
import 'package:vamorachar_telacadastro/widgets/validation_helpers.dart';
import 'package:vamorachar_telacadastro/constants/colors.dart';
import 'tela_inicial.dart';
import 'cadastro.dart';
import 'package:vamorachar_telacadastro/widgets/database_helper.dart';

class Login extends StatelessWidget {
  const Login({super.key});

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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final dbHelper = DatabaseHelper();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Route _homeRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const Home(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Route _cadastroRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const Cadastro(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Future<VoidCallback?> _submit() async {
    String? emailError = validateEmail(_emailController);
    String? passwordError = validatePassword(_passwordController);
    print("Botão de registrar pressionado");
    if (emailError == null &&
        passwordError == null) {
      print(_emailController.value.text);
      print(_passwordController.value.text);
      Map<String, Object?>? user = await dbHelper.findUser(_emailController.text);
      String? loginError = validateLogin(_passwordController, user);
      if (loginError != null){
        print("Erro no login - ${loginError}");
      } else {
        print("Login efetuado");
        Navigator.of(context).push(_homeRoute());
      }
    } else {
      print("Erro - os seguintes campos estão incorretos:");
      emailError != null ? print(emailError) : null;
      passwordError != null ? print(passwordError) : null;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      backgroundColor: const Color(verdePrimario),
      body:
      SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spread content between top and bottom
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
              child: Column(
                // Essa coluna representa a parte centralizada
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    height: 200,
                  ),
                  form(
                      "E-mail", //Label do TextField
                      Icons.account_circle_outlined, //Ícone do TextField
                      TextInputType.text, //Tipo do Teclado
                      _emailController, // Controlador do TextField
                      validateEmail(_emailController), // Verifica se há erro
                          (text) => setState(() => ()), // OnChanged
                      true // Enabled?
                  ),
                  passwordForm(
                    // hint, ico, controller, error, obscureText, toggleVisibility, onChanged, enabled
                      "Senha", //Lable do TextField
                      Icons.key_outlined, //Ícone do TextField
                      _passwordController, // Controlador do TextField
                      validatePassword(_passwordController), // Verifica se há erro
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
                        BorderRadius.circular(25.0), // Rounded corners
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100.0, vertical: 12.0),
                    ),
                    child: const Text('Login',
                        style: TextStyle(color: Color(0xEEEEEEEE))),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Não possui conta ?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).push(_cadastroRoute());
                          },
                          child: const Text(
                            "Registre-se",
                            style: TextStyle(
                              color: Color(0xEEEEEEEE),
                            ),
                          ))
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top:20, bottom: 20),
              child: Column(
                // Essa coluna representa a parte inferior
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Linha horizontal
                  Container(
                    width: 400,
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent, // Fading start
                          Colors.black,
                          Colors.transparent, // Fading end
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Space between the line and text
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(_homeRoute());
                    },
                    child: const Text(
                      "Entrar como convidado",
                      style: TextStyle(
                        color: Color(0xEEEEEEEE), // Text color changed to blue
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}
