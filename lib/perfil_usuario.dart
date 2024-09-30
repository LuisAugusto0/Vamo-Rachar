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
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override void dispose() {
    _userController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = "exemplo@email.com";
    _passwordController.text = "senh@forte";
    _userController.text = "Usuário";
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
        const Size.fromHeight(80), // Define a altura da AppBar como 0
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              IconButton(
                onPressed: (){
                Navigator.pop(context);
              }, icon: const Icon(Icons.close, size: 35,)),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(15), // Adiciona padding ao conteúdo
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                userAvatar(
                    "https://thispersondoesnotexist.com"), // Mover o avatar para o corpo
              ],
            ),
          ),
          form(
            "Usuário", //Label do TextField
            Icons.account_circle_outlined, //Ícone do TextField
            TextInputType.text, //Tipo do Teclado
            _userController, // Controlador do TextField
            validateUser(_userController), // Verifica se há erro
            (text) => setState(() => ()), // OnChanged
            true, // Enabled?
          ),
          form(
            "E-mail", //Label do TextField
            Icons.email_outlined, //Ícone do TextField
            TextInputType.emailAddress, //Tipo do Teclado
            _emailController, // Controlador do TextField
            validateEmail(_emailController), // Verifica se há erro
            (text) => setState(() => ()), // OnChanged
            false, // Enabled?
          ),
          senhaOculta(
            "Senha", //Label do TextField
            Icons.key_outlined, //Ícone do TextField
            TextInputType.text, //Tipo do Teclado
            _passwordController, // Controlador do TextField
            validatePassword(_passwordController), // Verifica se há erro
            (text) => setState(() => ()), // OnChanged
            false, // Enabled?
          ),
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
