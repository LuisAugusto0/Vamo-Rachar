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

  final TextEditingController _userText = TextEditingController();
  final TextEditingController _emailText = TextEditingController();
  final TextEditingController _passwordText = TextEditingController();
  final TextEditingController _passwordConfirmationText = TextEditingController();

  // Caracteres alfanuméricos
  // static final validCharacters = RegExp(r'^[a-zA-Z]');
  static final specialCharacters = RegExp(r'[!@#$%^&*(),.?":{}|<>]');


  @override
  void dispose() {
    _userText.dispose();
    _emailText.dispose();
    _passwordText.dispose();
    _passwordConfirmationText.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _userText.text = "Teste";
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String? get _errorUser {
    String? result;
    String password = _userText.value.text;
    if(password.isEmpty){
      result = "Escreva um nome de usuário";
    }
    return result;
  }
  String? get _errorEmail {
    String? result;
    String password = _emailText.value.text;
    if(password.length < 6 ){
      result = "Escreva um email";
    }
    return result;
  }
  String? get _errorPassword {
    String? result;
    String password = _passwordText.value.text;
    if(password.length < 6 ){
      result = "Mínimo 6 caracteres";
    } else if(!password.contains(specialCharacters)){
      result = "Necessita de pelomenos um caractere especial";
    }
    return result;
  }
  String? get _errorPasswordConfirm {
    String? result;
    String password = _passwordText.value.text;
    String passwordConfirmation = _passwordConfirmationText.value.text;
    if(password.compareTo(passwordConfirmation) != 0){
      result = "As senhas não estão iguais";
    }
    return result;
  }

  VoidCallback? _submit(){
    (text) => setState(() => _errorUser);
    (text) => setState(() => _errorEmail);
    (text) => setState(() => _errorPassword);
    (text) => setState(() => _errorPasswordConfirm);
    print("Botão de registrar pressionado");
    if(_errorEmail == null && _errorUser == null && _errorPassword == null && _errorPasswordConfirm == null ){
      print(_userText.value.text);
      print(_emailText.value.text);
      print(_passwordText.value.text);
      print(_passwordConfirmationText.value.text);
    } else {
      print("Erro - os seguintes campos estão incorretos:");
      _errorUser != null ? print(_errorUser) : null ;
      _errorEmail != null ? print(_errorEmail) : null ;
      _errorPassword != null ? print(_errorPassword) : null ;
      _errorPasswordConfirm != null ? print(_errorPasswordConfirm) : null ;

    }

    return null;
  }


  Widget form(String hint, IconData ico, TextInputType tip, TextEditingController controller, String? error){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
          keyboardType: tip,
          controller: controller,
          onChanged: (text) => setState(() => error),
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
              errorText: error,
              // labelStyle: const TextStyle(fontSize: 20.0, color: Colors.black54),
              // labelText: hint,
              border: OutlineInputBorder( borderSide: const BorderSide(color: Colors.black, width: 32.0), borderRadius: BorderRadius.circular(15.0)),
              focusedBorder: OutlineInputBorder( borderSide: const BorderSide(color: Colors.white, width: 32.0), borderRadius: BorderRadius.circular(15.0))
          )
      ),
    );
  }

  Widget passwordForm (String hint, IconData ico, TextEditingController controller, String? error){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        obscureText: _obscureText, // Toggle the visibility of the text
        onChanged: (text) => setState(() => error),
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
          errorText: error,
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
            padding: const EdgeInsets.only(top: 40, left: 60, right: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                form("Usuário", Icons.account_circle_outlined, TextInputType.text, _userText, _errorUser),
                form("E-mail", Icons.email_outlined, TextInputType.emailAddress, _emailText, _errorEmail),
                passwordForm("Senha", Icons.key_outlined, _passwordText, _errorPassword),
                passwordForm("Confirmar senha", Icons.key_outlined, _passwordConfirmationText, _errorPasswordConfirm),
                ElevatedButton(
                  onPressed: _submit,
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
