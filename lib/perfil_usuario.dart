import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vamorachar_telacadastro/widgets/form_widgets.dart';
import 'package:vamorachar_telacadastro/widgets/avatar_widget.dart';
import 'package:vamorachar_telacadastro/widgets/validation_helpers.dart';
import 'package:vamorachar_telacadastro/constants/colors.dart';

class Usuario extends StatelessWidget {
  const Usuario({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Perfil do usuário'),
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
  final TextEditingController _userText = TextEditingController();
  final TextEditingController _emailText = TextEditingController();
  final TextEditingController _passwordText = TextEditingController();

  @override void initState() {
    super.initState();
    _emailText.text = "exemplo@email.com";
    _passwordText.text = "Vi@dao";
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(240),
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              userAvatar("https://thispersondoesnotexist.com"),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          form("Usuário", Icons.account_circle_outlined, TextInputType.text,
              _userText, validateUser(_userText), (text) => setState(() => ()), true),
          form("E-mail", Icons.account_circle_outlined, TextInputType.emailAddress,
              _emailText, validateEmail(_emailText), (text) => setState(() => ()), false),
          senhaOculta("Senha", Icons.key_outlined, TextInputType.text,
              _passwordText, validatePassword(_passwordText), (text) => setState(() => ()), false),
        ],
      ),
      floatingActionButton: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16.0), // Margem nas laterais
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              onPressed: () {},
              foregroundColor: const Color(verdeSecundario),
              backgroundColor: const Color(verdePrimario),
              child: const Icon(Icons.logout),
            ),
            FloatingActionButton(
              onPressed: () {},
              foregroundColor: const Color(verdeSecundario),
              backgroundColor: const Color(verdePrimario),
              child: const Icon(Icons.check),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat, // Ajusta a localização
    );
  }
}
