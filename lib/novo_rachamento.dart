//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:gallery_picker/gallery_picker.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
//import 'package:novorachamento/card.dart';
//import 'tela_inicial.dart';

class Item {
  late String nome;
  late int quantidade;
  late double preco;

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
  late String CPF;
  late List<Item> itens = [];

  int identificarPosItem(String nome) {
    int pos = -1;
    for (int i = 0; i < itens.length; i++) {
      if (itens[i].nome.compareTo(nome) == 0) {
        pos = i;
        i = itens.length;
      }
    }
    return pos;
  }

  bool removeItem(Item item) {
    bool funcionou = true;
    int aux = identificarPosItem(item.nome);
    if(aux != -1) {
      if(itens[aux].quantidade > 1){
        itens[aux].quantidade--;
      }
      else if(itens[aux].quantidade == 1){
        itens.removeAt(aux);
      }
    }
    else{
      funcionou = false;
    }
    return funcionou;
  }

  void addItem(Item item) {
    int aux = identificarPosItem(item.nome);
    if(aux != -1){
      itens[aux].quantidade++;
    }
    else{
      Item aux = new Item.padrao(1, item.nome);
      itens.add(aux);
    }
  }

  Participante.create(String nome, int id) {
    this.id = id;
    this.nome = nome;
  }

  Participante() {
    id = -1;
    nome = "";
    CPF = "";
    itens = [];
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
    Item.padrao(3, "4")
  ];

  List<String> selectedOptions = [];

  //Função criada para adicionar participantes
  void _showPopup(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Preencha seu nome'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Seu nome'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                options.add(nameController.text);
                participantes.add(
                    Participante.create(nameController.text, ++ultimoIdUsado));
                Navigator.of(context).pop();
              },
              child: const Text('Enviar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
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
      if (participantes[i].nome.compareTo(comparativo) == 0) {
        pos = i;
        i = participantes.length;
      }
    }
    return pos;
  }

  int indentificarItem(String comparativo) {
    int pos = -1;
    for (int i = 0; i < itens.length; i++) {
      if (itens[i].nome.compareTo(comparativo) == 0) {
        pos = i;
        i = itens.length;
      }
    }
    return pos;
  }

//Função para adicionar itens
  void addItem(String nome, String nomeItem) {
    int posParticipante;

    posParticipante = indentificarParticipante(nome);
    print("Posicao participante: ${posParticipante} - nome do participante: ${participantes[posParticipante].nome}");

    int posItem = indentificarItem(nomeItem);
    for(int i = 0; i < participantes[posParticipante].itens.length; i++){
      print("Item: ${participantes[posParticipante].itens[i].nome} - quantidade: ${participantes[posParticipante].itens[i].quantidade}");
    }
    if (itens[posItem].quantidade > 0) {
      participantes[posParticipante].addItem(itens[posItem]);
      itens[posItem].quantidade--;
      for(int i = 0; i < participantes[posParticipante].itens.length; i++){
        print("BANANA TESTE BLA BLA BLA: ${participantes[posParticipante].itens[i].nome} - quantidade: ${participantes[posParticipante].itens[i].quantidade}");
      }
      print("Quantidade de itens restante: ${itens[posItem].quantidade}");
    }
  }

//Função para subtrair itens
  void subItem(nome, String nomeItem) {
    int posParticipante;

    posParticipante = indentificarParticipante(nome);

    int posItem = indentificarItem(nomeItem);
    for(int i = 0; i < participantes[posParticipante].itens.length; i++){
      print("Item: ${participantes[posParticipante].itens[i].nome} - quantidade: ${participantes[posParticipante].itens[i].quantidade}");
    }
    if (participantes[posParticipante].removeItem(itens[posItem])) {
      itens[posItem].quantidade++;
      for(int i = 0; i < participantes[posParticipante].itens.length; i++){
        print("Item: ${participantes[posParticipante].itens[i].nome} - quantidade: ${participantes[posParticipante].itens[i].quantidade}");
      }
    } else {
      print("Erro ao tentar remover, item não atribuido à esse participante\n");
    }
  }

  Scaffold iniciarTela() {
    String dropdownText = "Participantes";
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
          )
      ),
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
    );
  }

  Scaffold scanedScream() {
    String dropdownText = "Participantes";
    return Scaffold(
      backgroundColor: const Color(0xFF64C278),
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              setState(() {
                estado = 0;
              });
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
            final Item item = itens[index];
            int qtd = item.quantidade;
            late String textoPadrao = "Quantidade - ${qtd}";
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
                            setState(() {
                              for (int i = 0; i < selectedOptions.length; i++) {
                                addItem(selectedOptions[i], itens[index].nome);
                              }
                              qtd = itens[index].quantidade;
                              textoPadrao = "Quantidade - ${qtd}";
                            });
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
                            setState( (){
                              for (int i = 0; i < selectedOptions.length; i++) {
                                subItem(selectedOptions[i], itens[index].nome);
                              }
                              qtd = itens[index].quantidade;
                              textoPadrao = "Quantidade - ${qtd}";
                            });
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
