import 'package:flutter/material.dart';
import 'package:vamorachar_telacadastro/historico.dart';
import 'package:vamorachar_telacadastro/constants/colors.dart';
import 'package:vamorachar_telacadastro/widgets/navigation_helper.dart';
import 'package:vamorachar_telacadastro/widgets/database_helper.dart';
import 'login_inicial.dart';
import 'novo_rachamento.dart';
import 'perfil_usuario.dart';

class Home extends StatelessWidget {
  final String emailUsuario;
  Home({required this.emailUsuario});
  // Scaffold de scaffold??
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomePageAppBar(emailUsuario: emailUsuario,),
      body: const MyHomePage(),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Color(verdePrimario),
        //appBar: HomePageAppBar(),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RachamentoButton(),
                HistoricoButton()
              ],
            ),
          ],
        )
    );
  }
}

class HomePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String emailUsuario;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoggedIn = false;
  HomePageAppBar({required this.emailUsuario});


  Future<void> userProfileRoute(BuildContext context) async {
    final userData = await _dbHelper.getCurrentUser();

    if (userData != null) {
      return NavigationHelper.pushNavigatorTransitionDown(
        context,
        Usuario(emailUsuario: emailUsuario),
      );
    } else {
      // // Remove todas as telas anteriores até a primeira
      // Navigator.popUntil(context, (route) => route.isFirst);

      Navigator.of(context).popUntil( (Route<dynamic> route) => false );
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginInicial()));

      // Exibe mensagem informando que o usuário não está logado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não há nenhum usuário logado, faça login')),
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);


  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))),
      automaticallyImplyLeading: false,
      centerTitle: true,
      toolbarHeight: 100, // Ajuste a altura da AppBar aqui
      title: IconButton(
            icon: const Icon(
                Icons.account_circle_outlined,
                color: Colors.green,
                size: 50
            ),
            onPressed: () => userProfileRoute(context),
          ),
      );
  }
}


class RachamentoButton extends StatelessWidget {
  const RachamentoButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: FittedBox(
        child: FloatingActionButton.large(
          heroTag: 'btnNovaDivisao',
          backgroundColor: Colors.white,
          onPressed: () {
            NavigationHelper.pushNavigatorNoTransition(context, NovoRachamento());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/NovoRachamentoIcon.png",
                width: 50,
                height: 50,
              ),
              const SizedBox( //Fazer em padding depois
                height: 5,
              ),
              const Text("Nova Divisão",
                style:
                TextStyle(color: Colors.black, fontSize: 8)
              )
            ],
          ),
        ),
      ),
    );
  }
}

class HistoricoButton extends StatelessWidget {
  const HistoricoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: FittedBox(
        child: FloatingActionButton.large(
          heroTag: 'btnHistory',
          backgroundColor: Colors.white,
          onPressed: () {
            NavigationHelper.pushNavigatorNoTransition(context, const Historico());
          },
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.alarm,
                color: Colors.green,
                size: 50,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Histórico",
                style: TextStyle(color: Colors.black, fontSize: 8),
              )
            ],
          ),
        ),
      ),
    );
  }
}






