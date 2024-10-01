import 'package:flutter/material.dart';
import 'package:vamorachar_telacadastro/constants/colors.dart';
import 'perfil_usuario.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MyHomePage(),
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
    return Scaffold(
        backgroundColor: const Color(verdePrimario),
        appBar: AppBar(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))),
          automaticallyImplyLeading: false,
          centerTitle: true,
          toolbarHeight: 80, // Ajuste a altura da AppBar aqui
          title: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Centraliza verticalmente
            children: [
              IconButton(
                icon: const Icon(Icons.account_circle_outlined,
                    color: Colors.green, size: 50),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const Usuario(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, -1.0); // De cima para baixo
                        const end = Offset.zero;
                        const curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: FittedBox(
                    child: FloatingActionButton.large(
                      heroTag: 'btnNovaDivisao',
                      backgroundColor: Colors.white,
                      onPressed: null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/NovoRachamentoIcon.png",
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(height: 5,),
                          const Text("Nova Divisão",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 8))
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 200,
                  height: 200,
                  child: FittedBox(
                    child: FloatingActionButton.large(
                      heroTag: 'btnHistory',
                      backgroundColor: Colors.white,
                      onPressed: null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.alarm,
                            color: Colors.green,
                            size: 50,
                          ),
                          SizedBox(height: 5,),
                          Text(
                            "Histórico",
                            style: TextStyle(color: Colors.black, fontSize: 8),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ));
  }
}
