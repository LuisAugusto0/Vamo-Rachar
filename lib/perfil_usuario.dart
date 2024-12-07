import 'package:flutter/material.dart';
import 'package:vamorachar/database/sql_providers.dart';
import 'package:vamorachar/database/sql_tables.dart';
import 'login_inicial.dart';
import 'widgets/form_widgets.dart';
import 'widgets/avatar_widget.dart';
import 'widgets/validation_helpers.dart';
import 'constants/colors.dart';
import 'database/database_helper.dart';

class Usuario extends StatelessWidget {
  const Usuario({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _currentUserId = 0;
  bool isKeyboardVisible = false;
  String profileUrl = '';

  @override
  void dispose() {
    _userController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      isKeyboardVisible = bottomInset > 0;
    });
  }

  // Future<void> _loadUserData() async {
  //   final userData = await _dbHelper.findUser(emailUsuario);
  //
  //   if (userData != null) {
  //     setState(() {
  //       _userController.text = userData['nome'] as String;
  //       _emailController.text = userData['email'] as String;
  //       _passwordController.text = userData['senha'] as String;
  //     });
  //     _currentUserId = userData['id'] as int;
  //   }
  // }

  Future<void> _loadUserData() async {
    //OLD IMPLEMENTATION
    // final userData = await _dbHelper.getCurrentUser();

    // if (userData != null) {
    if (await _dbHelper.isLoggedIn()){
      setState(() async {
        // _userController.text = userData['nome'] as String;
        // _emailController.text = userData['email'] as String;
        // _passwordController.text = userData['senha'] as String;
        _userController.text = await _dbHelper.getCurrentUserName() as String;
        _emailController.text = await _dbHelper.getCurrentUserEmail() as String;
        _passwordController.text = "TemplateTemplate";
      });
      // _currentUserId = userData['id'] as int;
    }
    // else {
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(builder: (context) => LoginInicial()),
    //       (Route<dynamic> route) => false,
    // );

    // Navigator.of(context).popUntil( (Route<dynamic> route) => false );
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginInicial()));

    // Navigator.popUntil(context, (route) => route.isFirst);
    //
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Não há nenhum usuário logado, faça login')),
    // );
    // }
  }

  void _updateUserName() async {
    // LoginProvider provider = new LoginProvider(_dbHelper);
    //
    // await provider.updateByAutoIncrementId(
    //     LoginSql(name: _userController.text, email: _emailController.text, password: _passwordController.text),
    //     _currentUserId
    // );

    //REFAZER UPDATE
    // await _dbHelper.updateCurrentUser(_emailController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(await _dbHelper.updateUserName(_userController.text) ?? "Perfil atualizado com sucesso")),
    );
  }

  void _updateUserPassword() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(await _dbHelper.updateUserPassword(await _dbHelper.getCurrentUserEmail() as String, _oldPasswordController.text, _newPasswordController.text) ?? "Perfil atualizado com sucesso")),
    );
  }


  // void _alterarSenha() {
    // Verifica se a senha antiga está correta
    // String? oldPasswordError = validateOldPassword(_oldPasswordController, _passwordController);
    // if (oldPasswordError != null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(oldPasswordError)),
    //   );
    //   return;
    // }
    //
    // // Verifica se a nova senha é válida
    // String? newPasswordError = validatePassword(_newPasswordController);
    // if (newPasswordError != null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(newPasswordError)),
    //   );
    //   return;
    // }


    // Atualiza a senha se as validações passarem
    // setState(() {
    //   _passwordController.text = _newPasswordController.text;
    // });
    // _updateUserProfile(); // Salva a nova senha no banco de dados
  //   _updateUserPassword();
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Senha alterada com sucesso!')),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                if (isKeyboardVisible)
                  FloatingActionButton(
                    heroTag: 'btnSaveTopRight',
                    onPressed: () {
                      // _updateUserProfile();
                      _updateUserName();
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  userAvatarCustom(_dbHelper.getCurrentUserProfileURL()!),
                ],
              ),
            ),
            form(
              "Usuário",
              Icons.account_circle_outlined,
              TextInputType.text,
              _userController,
              null,
                  (text) => setState(() {}),
              true,
            ),
            form(
              "E-mail",
              Icons.email_outlined,
              TextInputType.emailAddress,
              _emailController,
              null,
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
                    null,
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
                                decoration: const InputDecoration(
                                    labelText: 'Senha Antiga'),
                              ),
                              TextField(
                                controller: _newPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    labelText: 'Nova Senha'),
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
                                _updateUserPassword();
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
            TextButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(await _dbHelper.createFirestoreBackup() ?? "Backup criado com sucesso")),
                );
              },
              child: const Text('Create backup'),
            ),
            TextButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(await _dbHelper.restoreFromFirestoreBackup() ?? "Restaurado com sucesso")),
                );
              },
              child: const Text('Restore backup'),
            ),
            TextButton(
              onPressed: () async {
                await _dbHelper.removeLocalDatabase();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Banco de dados local removido")),
                );
              },
              child: const Text('Remove local history'),
            ),
            TextButton(
              onPressed: () async {
                await _dbHelper.resetLocalDatabase();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Banco de dados local resetado")),
                );
              },
              child: const Text('Reset local history (debug initial values)'),
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: !isKeyboardVisible,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton.large(
                heroTag: 'btnLogout',
                onPressed: () async {
                  await _dbHelper.logOut();
                  await _dbHelper.removeLocalDatabase();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginInicial()),
                  );
                },
                foregroundColor: const Color(vermelhoLogOut),
                backgroundColor: const Color(vermelhoLogOut2),
                child: const Icon(Icons.logout),
              ),
              FloatingActionButton.large(
                heroTag: 'btnSave',
                onPressed: () {
                  // _updateUserProfile();
                  _updateUserName();
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
