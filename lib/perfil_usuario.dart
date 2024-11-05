import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vamorachar_telacadastro/login_inicial.dart';
import 'package:vamorachar_telacadastro/widgets/form_widgets.dart';
import 'package:vamorachar_telacadastro/widgets/avatar_widget.dart';
import 'package:vamorachar_telacadastro/widgets/validation_helpers.dart';
import 'package:vamorachar_telacadastro/constants/colors.dart';
import 'package:sqflite/sqflite.dart';

class Usuario extends StatelessWidget {
  const Usuario({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MyHomePage(title: 'Perfil do usuário'),
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
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = "exemplo@email.com";
    _passwordController.text = "senh@forte";
    _userController.text = "Usuário";
  }

  void _alterarSenha() {
    // Simule a verificação da senha antiga e a alteração para a nova senha
    if (validateOldPassword(_oldPasswordController, _passwordController) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validateOldPassword(_oldPasswordController, _passwordController) ?? 'Erro desconhecido')),
      );
    } else if(validatePassword(_passwordController) == null){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validatePassword(_passwordController) ?? 'Erro desconhecido')),
      );
    } else {
      setState(() {
        _passwordController.text = _newPasswordController.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_outlined,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                userAvatarCustom("https://thispersondoesnotexist.com"),
              ],
            ),
          ),
          form(
            "Usuário",
            Icons.account_circle_outlined,
            TextInputType.text,
            _userController,
            validateUser(_userController),
                (text) => setState(() {}),
            true,
          ),
          form(
            "E-mail",
            Icons.email_outlined,
            TextInputType.emailAddress,
            _emailController,
            validateEmail(_emailController),
                (text) => setState(() {}),
            false,
          ),
          Row(
            children: [
              Expanded(
                child: senhaOculta(
                  "Senha",
                  Icons.key_outlined,
                  TextInputType.text,
                  _passwordController,
                  validatePassword(_passwordController),
                      (text) => setState(() {}),
                  false,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                color: const Color(verdePrimario),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Alterar Senha'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _oldPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'Senha Antiga'),
                            ),
                            TextField(
                              controller: _newPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'Nova Senha'),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              _alterarSenha();
                              Navigator.pop(context);
                            },
                            child: const Text('Alterar'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Margem nas laterais
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton.large(
                heroTag: 'btnLogout',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginInicial()),
                  );
                },
                foregroundColor: const Color(vermelhoLogOut),
                backgroundColor: const Color(vermelhoLogOut2),
                child: const Icon(Icons.logout),
              ),
              FloatingActionButton.large(
                heroTag: 'btnSave',
                onPressed: () {
                  Navigator.pop(context);
                },
                foregroundColor: const Color(verdeSecundario),
                backgroundColor: const Color(verdePrimario),
                child: const Icon(Icons.check),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Ajusta a localização
    );
  }
}