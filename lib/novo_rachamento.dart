import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:gallery_picker/gallery_picker.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
//import 'package:novorachamento/card.dart';
import 'tela_inicial.dart';

class Item {
  late String nome;
  late int quantidade;

  Item() {
    quantidade = -1;
    nome = "";
  }

  Item.padrao(int quantidade, String nome) {
    this.quantidade = quantidade;
    this.nome = nome;
  }
}

class Participante {
  late int id;
  late String nome;
  late List<Item> itens = [];

  int identificarPosItem(String nome) {
    int pos = -1;
    for (int i = 0; i < this.itens.length; i++) {
      if (this.itens[i].nome.compareTo(nome) == 0) {
        pos = i;
        i = this.itens.length;
      }
    }
    return pos;
  }

  void removeItem(Item item) {
    for (int i = 0; i < this.itens.length; i++) {
      if (this.itens[i].nome.compareTo(item.nome) == 0) {
        if (this.itens[i].quantidade > 1) {
          this.itens[i].quantidade--;
        } else {
          this.itens.remove(item);
        }
      }
    }
  }

  void addItem(Item item) {
    if (this.itens.isNotEmpty) {
      bool itemFound = false;
      for (int i = 0; i < this.itens.length; i++) {
        if (this.itens[i].nome.compareTo(item.nome) == 0) {
          itemFound = true;
          this.itens[i].quantidade++;
          i = this.itens.length;
        }
      }
      if (!itemFound) {
        this.itens.add(item);
        this.itens[this.itens.length].quantidade++;
      }
    } else {
      this.itens.add(item);
    }
  }

  Participante.create(String nome, int id) {
    this.id = id;
    this.nome = nome;
  }

  Participante() {
    this.id = -1;
    this.nome = "";
    this.itens = [];
  }
}

void main(List<String> args) {
  runApp(MyApp());
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
  //Criando controladores dos cards
  //final TextEditingController _cardIdentifier = TextEditingController();
  //Indicador do estado da tela/ indicador de qual tela estamos
  int estado = 0;

  //Lista dos participantes acessível ao usuário
  List<String> options = [
    "Participante 1",
  ];

  //Lista dos participantes real
  int ultimoIdUsado = 1;
  List<Participante> participantes = [
    Participante.create("Participante 1", 1),
  ];

  //Lista de Itens
  List<Item> itens = [
    Item.padrao(5, "1"),
    Item.padrao(2, "2"),
    Item.padrao(6, "3"),
  ];

  List<String> selectedOptions = [];

  //Função criada para adicionar participantes
  void _showPopup(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Preencha seu nome'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: 'Seu nome'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                options.add(nameController.text);
                participantes.add(
                    Participante.create(nameController.text, ++ultimoIdUsado));
                Navigator.of(context).pop();
              },
              child: Text('Enviar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

//Função criada para remover participantes
  void _showPopup2(BuildContext context) {
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
                child: const Text("Aceitar"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancelar"),
              ),
            ],
          );
        });
  }

//Função para identificar a posição de uma String num vetor
  int indentificarParticipante(String comparativo) {
    int pos = -1;
    for (int i = 0; i < this.participantes.length; i++) {
      if (this.participantes[i].nome.compareTo(comparativo) == 0) {
        pos = i;
        i = this.participantes.length;
      }
    }
    return pos;
  }

  int indentificarItem(String comparativo) {
    int pos = -1;
    for (int i = 0; i < this.itens.length; i++) {
      if (this.itens[i].nome.compareTo(comparativo) == 0) {
        pos = i;
        i = this.itens.length;
      }
    }
    return pos;
  }

//Função para adicionar itens
  void addItem(String nome, String nomeItem) {
    int posParticipante;

    posParticipante = indentificarParticipante(nome);

    int posItem = indentificarItem(nomeItem);

    if (itens[posItem].quantidade > 0) {
      participantes[posParticipante].addItem(itens[posItem]);
      print("Antes de subtrair a quantidade: ${itens[posItem].quantidade}");
      itens[posItem].quantidade--;
      print("Depois de subtrair a quantidade: ${itens[posItem].quantidade}");
    }
  }

//Função para subtrair itens
  void subItem(nome, String nomeItem) {
    int posParticipante;

    posParticipante = indentificarParticipante(nome);

    int posItem = indentificarItem(nomeItem);

    if (participantes[posParticipante].itens.contains(itens[posItem])) {
      participantes[posParticipante].removeItem(itens[posItem]);
      itens[posItem].quantidade++;
    }
  }

  Scaffold iniciarTela() {
    String dropdownText = "Participantes";
    return Scaffold(
      backgroundColor: const Color(0xFF64C278),
      appBar: AppBar(
          toolbarHeight: 100,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDropdown<String>.multiSelectSearch(
                  hintText: dropdownText,
                  items: options,
                  onListChanged: (value) {
                    List<String> aux = [];
                    for (int i = 0; i < value.length; i++) {
                      aux.add(value[i]);
                    }
                    selectedOptions = aux;
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showPopup(context),
                      child: const Text(
                        "Adicionar Participante",
                        style: TextStyle(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showPopup2(context),
                      child: const Text(
                        "Remover Participante",
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    estado = 1;
                  });
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
            ],
          )
        ],
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Cancelar",
              style: TextStyle(
                color: Color.fromARGB(255, 54, 226, 143),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Scaffold scanedScream() {
    String dropdownText = "Participantes";
    return Scaffold(
      backgroundColor: const Color(0xFF64C278),
      appBar: AppBar(
          toolbarHeight: 100,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDropdown<String>.multiSelectSearch(
                  hintText: dropdownText,
                  items: options,
                  onListChanged: (value) {
                    List<String> aux = [];
                    for (int i = 0; i < value.length; i++) {
                      aux.add(value[i]);
                    }
                    selectedOptions = aux;
                  }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showPopup(context),
                        child: const Text(
                          "Adicionar Participante",
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showPopup2(context),
                        child: const Text(
                          "Remover Participante",
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Quantidade de caixas por linha
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: itens.length, // Quantidade total de itens
          itemBuilder: (context, index) {
            final item = itens[index];
            int qtd = item.quantidade;
            late String textoPadrao = "Quantidade - $qtd";
            return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.image,
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          textoPadrao,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shadowColor: Colors.transparent,
                            backgroundColor: Colors.transparent,
                          ),
                          onPressed: () {
                            for (int i = 0; i < selectedOptions.length; i++) {
                              addItem(selectedOptions[i], itens[index].nome);
                            }
                            //setState(() {
                            //qtd = itens[index].quantidade;
                            //textoPadrao = "Quantidade - $qtd";
                            //});
                          },
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.green,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shadowColor: Colors.transparent,
                            backgroundColor: Colors.transparent,
                          ),
                          onPressed: () {
                            for (int i = 0; i < selectedOptions.length; i++) {
                              subItem(selectedOptions[i], itens[index].nome);
                            }
                            //setState(() {
                            //qtd = itens[index].quantidade;
                            //textoPadrao = "Quantidade - $qtd";
                            //});
                          },
                          child: const Icon(
                            Icons.remove,
                            color: Colors.green,
                          ),
                        )
                      ],
                    ),
                  ],
                ));
          },
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                estado = 0;
              });
            },
            child: const Text(
              "Cancelar",
              style: TextStyle(
                color: Color.fromARGB(255, 54, 226, 143),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (estado) {
      case 0:
        return iniciarTela();
      case 1:
        return scanedScream();
      default:
        return const Text("Deu bobs, confere aí");
    }
  }
}
