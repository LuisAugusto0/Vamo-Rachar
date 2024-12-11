import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'historico.dart';
import 'constants/colors.dart';
import 'widgets/navigation_helper.dart';
import 'database/database_helper.dart';
import 'login_inicial.dart';
import 'novo_rachamento.dart';
import 'perfil_usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding

class Home extends StatelessWidget {
  Home({super.key});
  // Scaffold de scaffold??
  @override
  Widget build(BuildContext context) {
    _fetchLocation();

    return Scaffold(
      appBar: HomePageAppBar(),
      body: const MyHomePage(),
    );
  }

  Future<void> _fetchLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
      );




      //
      //
      // final url = 'https://nominatim.openstreetmap.org/search?format=json&limit=10&q=restaurant&lat=${position.latitude}&lon=${position.longitude}';
      // print(url);
      // final response = await http.get(Uri.parse(url));

      // if (response.statusCode == 200) {
      //   print(json.decode(response.body));
      // } else {
      //   throw Exception('Falha ao carregar restaurantes');
      // }

    } catch (e) {
      print("Error fetching location: $e");
    }
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
  final DatabaseHelper _dbHelper = DatabaseHelper();
  // final bool _isLoggedIn = false;
  final bool _isLoggedIn = false;
  HomePageAppBar({super.key});

  Future<void> userProfileRoute(BuildContext context) async {
    //OLD IMPLEMENTATION
    // final userData = await _dbHelper.getCurrentUser();
    //
    // if (userData != null) {
    if(await _dbHelper.isLoggedIn()){
      return NavigationHelper.pushNavigatorTransitionDown(
        context,
        Usuario(),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NovoRachamento()),
            );
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






