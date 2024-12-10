import 'dart:collection';

import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:gallery_picker/gallery_picker.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:vamorachar/database/sql_providers.dart';
import 'package:vamorachar/novo_rachamento_scanned.dart';
import 'confirmar_divisao.dart';
import 'database/sql_tables.dart';
import 'tela_inicial.dart';
import 'widgets/validation_helpers.dart';
import 'widgets/form_widgets.dart';
import 'database/database_helper.dart';
import 'widgets/navigation_helper.dart';
import 'scanner.dart';

class Item {
  late int id;
  late String nome;
  late int quantidade;
  late double preco;

  Item() {
    id = -1;
    quantidade = -1;
    nome = "";
    preco = -1;
  }

  Item.padrao(int id, int quantidade, String nome, double preco) {
    this.id = id;
    this.quantidade = quantidade;
    this.nome = nome;
    this.preco = preco;
  }
}

class Participante {
  late String nome;
  late String email;
  late double totalPago;

  Participante.create(String nome, int id, String email) {
    this.nome = nome;
    this.email = email;
    totalPago = 0;
  }

  Participante() {
    nome = "";
    email = "";
  }
}

class InstanciaItem {
  late Item item;
  late List<Participante> participantes;
  late int id;
  late double precoPago;
  late int quantidade;

  InstaciaItem() {
    id = -1;
    item = Item();
    participantes = [];
  }

  InstanciaItem.create(int id, Item item, List<Participante> participantes,
      double precoPago, int quantidade) {
    this.id = id;
    this.item = item;
    this.participantes = participantes;
    this.precoPago = precoPago;
    this.quantidade = quantidade;
  }
}

class MyApp extends StatelessWidget {
  //const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NovoRachamento(),
    );
  }
}

class NovoRachamento extends StatefulWidget {
  //const NovoRachamento({super.key});

  @override
  _NovoRachamentoState createState() => _NovoRachamentoState();
}

class _NovoRachamentoState extends State<NovoRachamento> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  //Lista dos participantes real
  int ultimoIdUsado = 0;
  int ultimoIdItem = 0;
  List<Participante> participantes = [];
  List<String> options = [];
  //Lista de Itens
  late List<Item> itens = [];

  //Função criada para adicionar itens à lista
  void _adicionarItens(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantidadeController = TextEditingController();
    final TextEditingController precoCrontroller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
              'Preencha o nome do Item, a quantidade consumida e seu preço'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                form(
                    "Nome do Item", //Label do TextField
                    Icons.abc, //Ícone do TextField
                    TextInputType.text, //Tipo do Teclado
                    nameController, // Controlador do TextField
                    validateUser(nameController), // Verifica se há erro
                    (text) => setState(() => ()), // OnChanged
                    true // Enabled?
                    ),
                form(
                    "Quantidade de itens consumidos", //Label do TextField
                    Icons.add_circle_outline, //Ícone do TextField
                    TextInputType.text, //Tipo do Teclado
                    quantidadeController, // Controlador do TextField
                    validateInteiro(
                        quantidadeController), // Verifica se há erro
                    (text) => setState(() => ()), // OnChanged
                    true // Enabled?
                    ),
                form(
                    "Preço do item consumidos", //Label do TextField
                    Icons.add_circle_outline, //Ícone do TextField
                    TextInputType.text, //Tipo do Teclado
                    precoCrontroller, // Controlador do TextField
                    validadeDouble(precoCrontroller), // Verifica se há erro
                    (text) => setState(() => ()), // OnChanged
                    true // Enabled?
                    ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  itens.add(new Item.padrao(
                      ultimoIdItem,
                      int.parse(quantidadeController.text),
                      nameController.text,
                      double.parse(precoCrontroller.text)));
                  ultimoIdItem++;
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                'Enviar',
                style: TextStyle(
                  color: Color.fromARGB(255, 54, 226, 143),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Color.fromARGB(255, 54, 226, 143),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  //Função criada para adicionar participantes
  void _adicionarParticipanteLista(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
              'Preencha seu nome e seu email, para adicionar um novo participante à lista'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              form(
                  "Usuário", //Label do TextField
                  Icons.account_circle_outlined, //Ícone do TextField
                  TextInputType.text, //Tipo do Teclado
                  nameController, // Controlador do TextField
                  validateUser(nameController), // Verifica se há erro
                  (text) => setState(() => ()), // OnChanged
                  true // Enabled?
                  ),
              form(
                  "Seu endereço de email", //Label do TextField
                  Icons.account_circle_outlined, //Ícone do TextField
                  TextInputType.text, //Tipo do Teclado
                  emailController, // Controlador do TextField
                  validateEmail(emailController), // Verifica se há erro
                  (text) => setState(() => ()), // OnChanged
                  true // Enabled?
                  ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                options.add(nameController.text);
                participantes.add(Participante.create(nameController.text,
                    ++ultimoIdUsado, emailController.text));
                Navigator.of(context).pop();
              },
              child: const Text(
                'Enviar',
                style: TextStyle(
                  color: Color.fromARGB(255, 54, 226, 143),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Color.fromARGB(255, 54, 226, 143),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

//Função criada para remover participantes
  void _removerParticipanteLista(BuildContext context) {
    List<String> aux = [];
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Selecione o Participante a Ser Removido"),
            content: CustomDropdown<String>.multiSelectSearch(
                hintText: "Participantes",
                items: options,
                onListChanged: (value) {
                  aux = value;
                }),
            actions: [
              ElevatedButton(
                onPressed: () {
                  for (int i = 0; i < aux.length; i++) {
                    options.remove(aux[i]);
                  }
                  for (int i = 0; i < aux.length; i++) {
                    for (int j = 0; j < participantes.length; j++) {
                      if (participantes[j].nome.compareTo(aux[i]) == 0) {
                        participantes.remove(participantes[j]);
                      }
                    }
                  }
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Aceitar",
                  style: TextStyle(
                    color: Color.fromARGB(255, 54, 226, 143),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Cancelar",
                  style: TextStyle(
                    color: Color.fromARGB(255, 54, 226, 143),
                  ),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF64C278),
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_outlined,
              size: 40,
            ),
          ),
          toolbarHeight: 100,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _adicionarParticipanteLista(context),
                      child: const Text(
                        "Adicionar",
                        style: TextStyle(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _removerParticipanteLista(context),
                      child: const Text(
                        "Remover",
                        style: TextStyle(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          )),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Scanner(
                                participantes: participantes,
                                itens: itens,
                                ultimoIdUsado: ultimoIdUsado,
                                ultimoIdItem: ultimoIdItem,
                              )));
                },
                child: const Text(
                  "Scanner",
                  style: TextStyle(
                    color: Color.fromARGB(255, 54, 226, 143),
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _adicionarItens(context);
                },
                child: const Text(
                  "Inserir Itens Manualmente",
                  style: TextStyle(
                    color: Color.fromARGB(255, 54, 226, 143),
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 50,
              right: 15,
            ),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NovoRachamentoScanner(
                            participantes: participantes,
                            itens: itens,
                            ultimoIdUsado: ultimoIdUsado)),
                  );
                });
              },
              child: const Text(
                "Prosseguir",
                style: TextStyle(
                  color: Color.fromARGB(255, 54, 226, 143),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
