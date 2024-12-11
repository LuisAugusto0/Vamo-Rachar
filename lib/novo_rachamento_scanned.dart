import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'novo_rachamento.dart';
import 'package:vamorachar/widgets/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'confirmar_divisao.dart';
import 'widgets/validation_helpers.dart';
import 'widgets/form_widgets.dart';

class NovoRachamentoScanner extends StatelessWidget {
  final List<Participante> participantes;
  final List<Item> itens;
  int ultimoIdUsado;

  NovoRachamentoScanner(
      {Key? key,
      required this.participantes,
      required this.itens,
      required this.ultimoIdUsado});

  @override
  Widget build(BuildContext context) {
    return ScannedScreen(
      participantes: participantes,
      itens: itens,
      ultimoIdUsado: ultimoIdUsado,
    );
  }
}

class ScannedScreen extends StatefulWidget {
  final List<Participante> participantes;
  final List<Item> itens;
  int ultimoIdUsado;

  ScannedScreen(
      {Key? key,
      required this.participantes,
      required this.itens,
      required this.ultimoIdUsado}) {}

  @override
  _ScannedScreen createState() => _ScannedScreen(
      participantes: participantes, itens: itens, ultimoIdUsado: ultimoIdUsado);
}

class _ScannedScreen extends State<ScannedScreen> {
  //Variáveis Globais
  final List<Participante> participantes;
  late List<InstanciaItem> instancias;
  final List<Item> itens;
  int ultimoIdUsado;
  late int ultimoIdInstancia;
  List<String> options = [];
  List<String> quemPodeSerRemovido = [];

  //Construtor
  _ScannedScreen(
      {Key? key,
      required this.participantes,
      required this.itens,
      required this.ultimoIdUsado}) {
    for (int i = 0; i < participantes.length; i++) {
      options.add(participantes[i].nome);
    }
    instancias = [];
    ultimoIdInstancia = 0;
  }

  //Métodos Auxiliares/Acessórios

  //Método para adicionar participantes à lista de participantes
  void _adicionarParticipanteLista(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
              'Preencha seu nome, para adicionar um novo participante à lista'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              form(
                  "Usuário", //Label do TextField
                  Icons.account_circle_outlined, //Ícone do TextField
                  TextInputType.text, //Tipo do Teclado
                  nameController, // Controlador do TextField
                  "", // Verifica se há erro
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

  //Método para remover participantes da lista de participantes
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

  //Função auxiliar para identificar o participante pelo nome
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

  //Método utilizado para criar instâncias de itens
  void addItem(List<Participante> lista, Item item) {
    double auw = item.preco;
    auw = auw / lista.length;
    bool achou = false;
    if (instancias.length > 0) {
      for (int i = 0; i < lista.length; i++) { 
        debugPrint("LISTA[${i}]: ${lista[i].nome}");
      }
      for (int i = 0; i < instancias.length; i++) {
        debugPrint(
            "INSTANCIAS.ITEM.ID: ${instancias[i].item.id} - ITEM.ID: ${item.id} ");
        debugPrint(
            "INSTANCIAS.ITEM.PRECO: ${instancias[i].precoPago} - ITEM.PRECO: ${auw}");
        debugPrint(
            "INSTANCIAS.PARTICIPANTES.LENGTH: ${instancias[i].participantes.length} - PARTICIPANTES.LENGTH: ${lista.length}");
        if (instancias[i].item.id == item.id &&
            instancias[i].precoPago == auw && instancias[i].participantes.length == lista.length) {
          debugPrint("CAI AQUI!");
          int iguais = 0;
          int z = 0, j = 0;
          for (j = 0; j < instancias[i].participantes.length; j++) {
            for (z = 0; z < lista.length; z++) {
              if (instancias[i].participantes[j].nome.compareTo(lista[z].nome) == 0) {
                iguais++;
              }
            }
          }
          if (iguais == lista.length) {
            instancias[i].quantidade++;
            debugPrint("Lista tem os mesmos integrantes da instância");
            achou = true;
          }
        }
      }
      if (!achou) {
        instancias.add(new InstanciaItem.create(ultimoIdInstancia, item, lista, auw, 1));
        ultimoIdInstancia++;
        debugPrint("Lista não tem os mesmos integrantes");
      }
    } else {
      debugPrint("PRIMEIRO ELSE");
      instancias.add(new InstanciaItem.create(ultimoIdInstancia, item, lista, auw, 1));
      ultimoIdInstancia++;
    }
  }

  //Método que cria aba responsável por realisar o processo de adicionar um divisor a um item
  void _adicionarDivisor(BuildContext context, int index) {
    List<Participante> aux = [];
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                  "Selecione os Participantes que Vão Rachar esse Item"),
              content: Column(
                children: [
                  CustomDropdown<String>.multiSelectSearch(
                      hintText: "Quem rachou esse item?",
                      items: options,
                      onListChanged: (value) {
                        for (int i = 0; i < value.length; i++) {
                          debugPrint("VALUE[${i}]: ${value.elementAt(i)}");
                        }
                        aux.removeRange(0, aux.length);
                        debugPrint("${value}");
                        for (int i = 0; i < value.length; i++) {
                          Participante auy =
                              participantes[identificarParticipante(value[i])];
                          if (!aux.contains(auy)) {
                            aux.add(auy);
                          }
                        }
                      }),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    for (int i = 0; i < aux.length; i++) {
                      debugPrint("AUX[${i}]: ${aux[i].nome}");
                    }
                    if(aux.length > 0){
                      addItem(aux, itens[index]);
                      setState(() {
                        itens[index].quantidade--;
                      });  
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
            ));
  }

  //Função auxiliar utilizada para criar um diálogo de alerta avisando sobre a não existência de uma instância para um determinado item
  void _instanciaNaoEncontrada(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Instância não encontrada"),
            content:
                const Text("Favor verificar os participantes selecionados"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Ok",
                  style: TextStyle(
                    color: Color.fromARGB(255, 54, 226, 143),
                  ),
                ),
              ),
            ],
          );
        });
  }

  //Função auxiliar utilizada para identificar todas as instâncias que um determinado item possui
  List<InstanciaItem> identificarInstanciaItem(Item item) {
    List<InstanciaItem> listinstancias = [];
    for (int i = 0; i < instancias.length; i++) {
      if (instancias[i].item.id == item.id) {
        listinstancias.add(instancias[i]);
      }
    }
    return listinstancias;
  }

  //Função utilizada para atualizar/deletar instâncias de itens
  void subItem(List<Participante> lista, InstanciaItem instancia) {
    debugPrint(
        "INSTANCIAS.LENGTH: ${instancia.participantes.length} - PARTICIPANTES.LENGTH: ${lista.length}");
    if (instancia.participantes.length == lista.length) {
      if (instancia.quantidade > 1) {
        instancia.quantidade--;
        itens[instancia.item.id].quantidade++;
        debugPrint("1");
      } else {
        instancias.remove(instancia);
        itens[instancia.item.id].quantidade++;
        debugPrint("2");
      }
    } else {
      Set<Participante> aux = lista.toSet();
      Set<Participante> auy = instancia.participantes.toSet();
      aux = auy.intersection(aux);
      auy = auy.difference(aux);
      if (instancia.quantidade > 1) {
        instancia.quantidade--;
        instancias.add(
            new InstanciaItem.create(ultimoIdInstancia, instancia.item, auy.toList(), instancia.precoPago, 1));
        ultimoIdInstancia++;
        debugPrint("3");
      } else {
        instancias.remove(instancia);
        instancias.add(
            new InstanciaItem.create(ultimoIdInstancia, instancia.item, auy.toList(), instancia.precoPago, 1));
        ultimoIdInstancia++;
        debugPrint("4");
      }
    }
  }

  //Método que cria aba responsável por realisar o processo de remover um divisor de um item
  void _removerDivisor(BuildContext context, int index) {
    int identificadorDeInstancia = -1;
    List<Participante> aux = [];
    List<InstanciaItem> instancias = identificarInstanciaItem(itens[index]);
    List<String> participantesElegiveis = [];
    setState(() {
      quemPodeSerRemovido.removeRange(0, quemPodeSerRemovido.length);
    });
    debugPrint("${instancias}");
    if (instancias.length > 0) {
      for (int i = 0; i < instancias.length; i++) {
        String temp = "";
        temp += (i + 1).toString() + " - ";
        for (int j = 0; j < instancias[i].participantes.length - 1; j++) {
          temp += instancias[i].participantes[j].nome + ", ";
        }
        temp += instancias[i].participantes[instancias[i].participantes.length - 1].nome;
        participantesElegiveis.add(temp);
      }
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                  "Selecione o Participante a Ser Removido do Rachamento"),
              content: Column(
                children: [
                  CustomDropdown<String>.search(
                      hintText: "Quem rachou esse item?",
                      items: participantesElegiveis,
                      onChanged: (value) {
                        debugPrint(value);
                        String? temp = "";
                        if (value != null) {
                          temp += value.characters.elementAt(0);
                        }
                        identificadorDeInstancia = int.parse(temp) - 1;
                        if (quemPodeSerRemovido.length > 0) {
                          setState(() {
                            quemPodeSerRemovido.removeRange(0, quemPodeSerRemovido.length);
                          });
                        }
                        setState(() {
                          for (int i = 0; i < instancias[identificadorDeInstancia].participantes.length; i++) {
                            quemPodeSerRemovido.add(instancias[identificadorDeInstancia].participantes[i].nome);
                          }
                        });
                      }),
                  CustomDropdown<String>.multiSelectSearch(
                      hintText: "Quem será removido?",
                      items: quemPodeSerRemovido,
                      onListChanged: (value) {
                        aux.removeRange(0, aux.length);
                        for (int i = 0; i < value.length; i++) {
                          debugPrint("VALUE[${i}]: ${value.elementAt(i)}");
                        }
                        debugPrint("Tam instância: ${instancias[identificadorDeInstancia].participantes.length}");
                        for (int i = 0; i < instancias[identificadorDeInstancia].participantes.length; i++) {
                          debugPrint(
                              "Participantes da instância: ${instancias[identificadorDeInstancia].participantes[i].nome}");
                        }
                        for (int i = 0; i < value.length; i++) {
                          Participante auy = participantes[identificarParticipante(value[i])];
                          if (!aux.contains(auy)) {
                            aux.add(auy);
                          }
                        }
                        for (int i = 0; i < aux.length; i++) {
                          debugPrint(
                              "Participantes[${i}]: ${aux.elementAt(i).nome}");
                        }
                        for (int i = 0; i < instancias[identificadorDeInstancia].participantes.length; i++) {
                          debugPrint("Participantes da instância: ${instancias[identificadorDeInstancia].participantes[i].nome}");
                        }
                      }),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (instancias.length > 0) {
                      subItem(aux, instancias[identificadorDeInstancia]);
                    }
                    setState(() {});
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
    } else {
      _instanciaNaoEncontrada(context);
    }
  }

  //Método que edita as informações de um determinado item
  void _editarItem(BuildContext context, int index) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantidadeController = TextEditingController();
    final TextEditingController precoController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: AlertDialog(
            title: const Text('Preencha apenas os campos que deseja alterar'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                form(
                    "Nome atual: ${itens[index].nome}", //Label do TextField
                    Icons.account_circle_outlined, //Ícone do TextField
                    TextInputType.text, //Tipo do Teclado
                    nameController, // Controlador do TextField
                    validateUser(nameController), // Verifica se há erro
                    (text) => setState(() => ()), // OnChanged
                    true // Enabled?
                    ),
                form(
                    "Quantidade atual: ${itens[index].quantidade}", //Label do TextField
                    Icons.account_circle_outlined, //Ícone do TextField
                    TextInputType.number, //Tipo do Teclado
                    quantidadeController, // Controlador do TextField
                    validateUser(quantidadeController), // Verifica se há erro
                    (text) => setState(() => ()), // OnChanged
                    true // Enabled?
                    ),
                form(
                    "Preço atual: ${itens[index].preco}", //Label do TextField
                    Icons.account_circle_outlined, //Ícone do TextField
                    TextInputType.number, //Tipo do Teclado
                    precoController, // Controlador do TextField
                    validateUser(precoController), // Verifica se há erro
                    (text) => setState(() => ()), // OnChanged
                    true // Enabled?
                    ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      nameController.text != itens[index].nome &&
                      nameController.text != " " &&
                      nameController.text != "") {
                    setState(() {
                      itens[index].nome = nameController.text;
                    });
                  }
                  if (quantidadeController.text.isNotEmpty &&
                      quantidadeController.text !=
                          itens[index].quantidade.toString() &&
                      quantidadeController.text != " " &&
                      quantidadeController.text != "") {
                    setState(() {
                      itens[index].quantidade =
                          int.parse(quantidadeController.text);
                    });
                  }
                  if (precoController.text.isNotEmpty &&
                      precoController.text != itens[index].preco.toString() &&
                      precoController.text != " " &&
                      precoController.text != "") {
                    setState(() {
                      itens[index].preco = double.parse(precoController.text);
                    });
                  }
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
          ),
        );
      },
    );
  }

  //Método Build
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
              ),
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
            late String textoPadrao = "${item.nome}\nQuantidade - ${qtd}\nPreço - R\$${preco}";
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
                        Flexible(
                          child: Text(
                          textAlign: TextAlign.center,
                          textoPadrao,
                          softWrap: true,
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _editarItem(context, index);
                          },
                          child: Icon(
                            Icons.edit,
                            color: Colors.green,
                          ),
                          style: ElevatedButton.styleFrom(
                            shadowColor: Colors.transparent,
                            backgroundColor: Colors.transparent,
                          ),
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
                              if (itens[index].quantidade > 0) {
                                _adicionarDivisor(context, index);
                              }
                              //aux.removeRange(0, aux.length);
                              qtd = itens[index].quantidade;
                              textoPadrao =
                                  "${item.nome}\nQuantidade - ${qtd}\nPreço - R\$${preco}";
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
                            setState(() {
                              _removerDivisor(context, index);
                              qtd = itens[index].quantidade;
                              textoPadrao =
                                  "${item.nome}\nQuantidade - ${qtd}\nPreço - R\$${preco}";
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
                NavigationHelper.pushNavigatorNoTransition(
                    context,
                    ConfirmarDivisao(
                        participantes: participantes, instancias: instancias));
              },
              child: Text(
                "Enviar",
                style: TextStyle(
                  color: Color.fromARGB(255, 54, 226, 143),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
