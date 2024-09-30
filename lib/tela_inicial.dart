import 'package:flutter/material.dart';
import 'perfil_usuario.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vamo Rachar',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF64C27B),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
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
        appBar: AppBar(
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
                    MaterialPageRoute(builder: (context) => const Usuario()),
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
