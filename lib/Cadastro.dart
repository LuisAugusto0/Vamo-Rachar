import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Cadastro extends StatelessWidget {
  const Cadastro({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF64C278),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Tela de cadastro'),
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
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  VoidCallback? onPressed(){
    print("Botão de registrar pressionado");
    return null;
  }



  Widget form(String hint, IconData ico){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
          style: const TextStyle(
            fontSize: 25.0,
            color: Colors.black,
          ),
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              prefixIcon: Icon(ico, color: Colors.black,),
              hintStyle: const TextStyle(fontSize: 20.0, color: Colors.black54),
              hintText: hint,
              // labelStyle: const TextStyle(fontSize: 20.0, color: Colors.black54),
              // labelText: hint,
              border: OutlineInputBorder( borderSide: const BorderSide(color: Colors.black, width: 32.0), borderRadius: BorderRadius.circular(15.0)),
              focusedBorder: OutlineInputBorder( borderSide: const BorderSide(color: Colors.white, width: 32.0), borderRadius: BorderRadius.circular(15.0))
          )
      ),
    );
  }

  Widget passwordForm (String hint, IconData ico, TextEditingController controller){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        obscureText: _obscureText, // Toggle the visibility of the text
        style: const TextStyle(
          fontSize: 25.0,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          prefixIcon: const Icon(Icons.lock, color: Colors.black), // Example icon
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.black,
            ),
            onPressed: _toggleVisibility,
          ),
          hintStyle: const TextStyle(fontSize: 20.0, color: Colors.black54),
          hintText: hint,
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2.0), // Adjust width as needed
            borderRadius: BorderRadius.circular(15.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2.0), // Adjust width as needed
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return Scaffold(

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                height: 200,
              ),
            ],
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                form("Usuário", Icons.account_circle_outlined),
                form("E-mail", Icons.email_outlined),
                passwordForm("Senha", Icons.key_outlined, _controller1),
                passwordForm("Confirmar senha", Icons.key_outlined, _controller2),

                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0), // Padding inside the button
                  ),
                  child: const Text('Registrar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
