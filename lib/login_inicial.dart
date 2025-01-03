import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/colors.dart';
import 'sobre.dart';
import 'database/database_helper.dart'  ;
import 'widgets/navigation_helper.dart';
import 'tela_inicial.dart';
import 'cadastro.dart';
import 'login.dart';


class LoginInicial extends StatelessWidget {
  const LoginInicial({super.key});

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
// Boolean para trocar visibilidade

  final TextEditingController _userText = TextEditingController();
  final TextEditingController _emailText = TextEditingController();
  final TextEditingController _passwordText = TextEditingController();
  final TextEditingController _passwordConfirmationText = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool isLoggedIn = false;

  @override
  void initState() {
    verifyLogin();
    super.initState();
  }

  @override
  void dispose() {
    _userText.dispose();
    _emailText.dispose();
    _passwordText.dispose();
    _passwordConfirmationText.dispose();
    super.dispose();
  }

  Future<void> verifyLogin() async{
    // OLD IMPLEMENTATION
    // Map<String, Object?>? user = await _dbHelper.getCurrentUser();
    
    // if (user != null){
    if (await _dbHelper.isLoggedIn()){
      NavigationHelper.pushNavigatorNoTransition(context, Home());
    }
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

  Route _homeRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Home(),
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

  Route _loginRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const Login(),
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      backgroundColor: const Color(verdePrimario),
      body:
      Column(
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween, // Spread content between top and bottom
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(onPressed: (){
                  NavigationHelper.pushNavigatorNoTransition(context, const SobreNos());
                }, icon: const Icon(Icons.question_mark_outlined, color: Color(0xEEEEEEEE), size: 35,)),
              ],
            ),
          ), //Texto vazio apenas para centralizar a coluna a seguir
          Column(
            // Essa coluna representa a parte centralizada
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                height: 200,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(_loginRoute());
                },
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
              Padding(
                padding: const EdgeInsets.all(20.0),
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
          Text(""),
        ],
      ),
    );
  }
}
