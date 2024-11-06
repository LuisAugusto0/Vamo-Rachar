//import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:gallery_picker/gallery_picker.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
//import 'package:novorachamento/card.dart';
//import 'tela_inicial.dart';

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

class InstanciaItem {
  late Item item;
  late List<Participante> participantes;
  late int id;

  InstaciaItem() {
    id = -1;
    item = new Item();
    participantes = [];
  }

  InstanciaItem.create(int id, Item item, List<Participante> participantes){
    this.id = id;
    this.item = item;
    this.participantes = participantes;
  }

}

class Participante {
  late int id;
  late String nome;
  late String email;

  Participante.create(String nome, int id, String email) {
    this.id = id;
    this.nome = nome;
    this.email = email;
  }

  Participante() {
    id = -1;
    nome = "";
    email = "";
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
  int ultimoIdUsado = 0;
  int ultimoIdInstancia = 0;
  List<Participante> participantes = [
    Participante.create("Participante 1", 0, "teste@gmail.com"),
  ];

  //Lista de Itens
  late List<Item> itens = [];

  //
  late List<InstanciaItem> instancias;

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
                  Participante.create(nameController.text, ++ultimoIdUsado, "teste@gmail.com")
                );
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
  int identificarParticipante(String comparativo) {
    int pos = -1;
    for (int i = 0; i < this.participantes.length; i++) {
      if (participantes[i].nome.compareTo(comparativo) == 0) {
        pos = i;
        i = participantes.length;
      }
    }
    return pos;
  }

  int identificarItem(String comparativo) {
    int pos = -1;
    for (int i = 0; i < itens.length; i++) {
      if (itens[i].nome.compareTo(comparativo) == 0) {
        pos = i;
        i = itens.length;
      }
    }
    return pos;
  }

//Função para calcular o gasto total de um usuário/participante
  double getTotalPago(Participante participante){
    double total = 0;
    for(int i = 0; i < instancias.length; i++){
      if(instancias[i].participantes.contains(participante)){
        total += instancias[i].item.preco * instancias[i].item.quantidade;
      }
    }
    return total;
  }  
  
//Função para adicionar itens
  void addItem(List<Participante> participantes, Item item) {
    Item aux = new Item.padrao(item.id, 1, item.nome, item.preco/participantes.length);


    if(instancias.length > 0){
      for(int i = 0; i < instancias.length; i++){
        print("INSTANCIAS.ITEM.ID: ${instancias[i].item.id} - ITEM.ID: ${item.id} ");
        print("INSTANCIAS.ITEM.PRECO: ${instancias[i].item.preco} - ITEM.PRECO: ${item.preco}");
        print("INSTANCIAS.PARTICIPANTES.LENGTH: ${instancias[i].participantes.length} - PARTICIPANTES.LENGTH: ${participantes.length}");
        if(instancias[i].item.id == item.id
            && instancias[i].item.preco == aux.preco
            && instancias[i].participantes.length == participantes.length) {
          print("CAI AQUI!");
          bool diferente = true;
          int z = 0,
              j = 0;
          while (diferente && j < instancias[i].participantes.length) {
            for (j = 0; j < instancias[i].participantes.length; j++) {
              if (instancias[i].participantes[j].nome.compareTo(
                  participantes[z].nome) == 0) {
                z++;
                j = 0;
              }
              if (z == participantes.length) {
                diferente = false;
              }
            }
          }
          if(!diferente){
            instancias[i].item.quantidade++;
          }
        } else {
          print("SEGUNDO ELSE");
          instancias.add(new InstanciaItem.create(ultimoIdInstancia, aux, participantes));
          ultimoIdInstancia++;
          break;
        }
      }
    } else {
      print("PRIMEIRO ELSE");
      instancias.add(new InstanciaItem.create(ultimoIdInstancia, aux, participantes));
      ultimoIdInstancia++;
    }
  }

//Função para subtrair itens
  void subItem(String nome, int posItem) {

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
                    for(int i = 0; i < 5; i++){
                      Item aux = new Item.padrao(i, (i + 1) * 3, (i + 1).toString(), (i + 1) * 5);
                      itens.add(aux);
                    }
                    estado = 1;
                    instancias = [];

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
            String preco = item.preco.toStringAsFixed(2);
            late String textoPadrao = "Quantidade - ${qtd}\nPreço - R\$${preco}";
            return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                              List<Participante> aux = [];
                              for (int i = 0; i < selectedOptions.length; i++) {
                                aux.add(participantes[identificarParticipante(selectedOptions[i])]);
                              }
                              if(selectedOptions.length >= 1 && itens[index].quantidade > 0){
                                addItem(aux, itens[index]);
                                itens[index].quantidade--;
                              }
                              qtd = itens[index].quantidade;
                              textoPadrao = "Quantidade - ${qtd}\nPreço - R\$${preco}";
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
                                subItem(selectedOptions[i], index);
                              }
                              qtd = itens[index].quantidade;
                              textoPadrao = "Quantidade - ${qtd}\nPreço - R\$${preco}";
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
                )
            );
          },
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: (){
                for(int i = 0; i < participantes.length; i++){
                  print("Nome: ${participantes[i].nome} - Preco pago: ${getTotalPago(participantes[i])}");
                }
                for(int i = 0; i < instancias.length; i++){
                  print("ID: ${instancias[i].id} - Nome Item: ${instancias[i].item.nome} - Custo item: ${instancias[i].item.preco} - Quantidade de itens: ${instancias[i].item.quantidade}");
                  for(int j = 0; j < instancias[i].participantes.length; j++){
                    print("Nome do participante[${j}]: ${instancias[i].participantes[j].nome}");
                  }
                }
              },
              child: Text(
                "Enviar",
              ),
          )
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
