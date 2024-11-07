import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:gallery_picker/gallery_picker.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:vamorachar_telacadastro/widgets/validation_helpers.dart';
import 'package:vamorachar_telacadastro/widgets/form_widgets.dart';
import 'package:vamorachar_telacadastro/widgets/database_helper.dart';

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

  final DatabaseHelper _dbHelper = DatabaseHelper();

  //Indicador do estado da tela/ indicador de qual tela estamos
  int estado = 0;

  //Lista dos participantes acessível ao usuário
  List<String> options = [];

  //Lista dos participantes real
  int ultimoIdUsado = 0;
  int ultimoIdInstancia = 0;
  int ultimoIdItem = 0;
  List<Participante> participantes = [];

  //Lista de Itens
  late List<Item> itens = [];

  //Lista de todas as divisões/compras feitas
  late List<InstanciaItem> instancias;

  //Lista de Participantes da Lista de options selecionados
  List<String> selectedOptions = [];

  void _scanner(BuildContext){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("Ainda não implementado, favor aguardar atualizações futuras"),
            content: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Voltar"),
            ),
          );
        }
    );
  }

  //Função criada para adicionar itens à lista
  void _adicionarItens(BuildContext context){
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantidadeController = TextEditingController();
    final TextEditingController precoCrontroller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Preencha o nome do Item, a quantidade consumida e seu preço'),
          content: Column(
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
                  validateInteiro(quantidadeController), // Verifica se há erro
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
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  itens.add(
                      new Item.padrao(ultimoIdItem, int.parse(quantidadeController.text), nameController.text, double.parse(precoCrontroller.text))
                  );
                  ultimoIdItem++;
                });
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

  //Função criada para adicionar participantes
  void _adicionarParticipanteLista(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Preencha seu nome e seu email, para adicionar um novo participante à lista'),
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
                participantes.add(
                    Participante.create(nameController.text, ++ultimoIdUsado, emailController.text)
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

//Função criada para identificar quem vai deixar de pagar um determinado item
  void _removerDivisor(BuildContext context, InstanciaItem instancia){
    List<Participante> aux = [];
    showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Selecione o Participante a Ser Removido do Rachamento"),
        content: CustomDropdown<String>.multiSelectSearch(
            hintText: "Participantes",
            items: selectedOptions,
            onListChanged: (value) {
              for(int i = 0; i < value.length; i++){
                print("VALUE[${i}]: ${value.elementAt(i)}");
              }
              for(int i = 0; i < value.length; i++){
                Participante auy = participantes[identificarParticipante(value[i])];
                if(!aux.contains(auy)){
                  aux.add(auy);
                }
              }
            }),
        actions: [
          ElevatedButton(
            onPressed: () {
              subItem(aux, instancia);
              setState(() {

              });
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

//Função para identificar uma instância específica, baseando-se nos participantes e no item
  InstanciaItem ? identificarInstancia(Item item, List<Participante> lista){
    InstanciaItem ? instancia;
    Item aux = new Item.padrao(item.id, 1, item.nome, item.preco/lista.length);
    for(int i = 0; i < instancias.length; i++){
      print("INSTANCIAS.ITEM.ID: ${instancias[i].item.id} - ITEM.ID: ${aux.id} ");
      print("INSTANCIAS.ITEM.PRECO: ${instancias[i].item.preco} - ITEM.PRECO: ${aux.preco}");
      print("INSTANCIAS.PARTICIPANTES.LENGTH: ${instancias[i].participantes.length} - PARTICIPANTES.LENGTH: ${lista.length}");
      if(instancias[i].item.id == aux.id
          && instancias[i].item.preco == aux.preco
          && instancias[i].participantes.length == lista.length) {
        int iguais = 0;
        int z = 0,
            j = 0;
        for(j = 0; j < instancias[i].participantes.length; j++){
          for(z = 0; z < lista.length; z++){
            if(instancias[i].participantes[j].nome.compareTo(lista[z].nome) == 0){
              iguais++;
            }
          }
        }
        if(iguais == lista.length){
          instancia = instancias[i];
          i = instancias.length;
        }
      }
    }
    return instancia;
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
  void addItem(List<Participante> lista, Item item) {
    double auw = item.preco;
    bool existe = false;
    Item aux = new Item.padrao(item.id, 1, item.nome, auw/lista.length);
    if(instancias.length > 0){
      for(int i = 0; i < instancias.length; i++){
        print("INSTANCIAS.ITEM.ID: ${instancias[i].item.id} - ITEM.ID: ${aux.id} ");
        print("INSTANCIAS.ITEM.PRECO: ${instancias[i].item.preco} - ITEM.PRECO: ${aux.preco}");
        print("INSTANCIAS.PARTICIPANTES.LENGTH: ${instancias[i].participantes.length} - PARTICIPANTES.LENGTH: ${lista.length}");
        if(instancias[i].item.id == aux.id
            && instancias[i].item.preco == aux.preco
            && instancias[i].participantes.length == lista.length) {
          print("CAI AQUI!");
          int iguais = 0;
          int z = 0,
              j = 0;
          for(j = 0; j < instancias[i].participantes.length; j++){
            for(z = 0; z < lista.length; z++){
              if(instancias[i].participantes[j].nome.compareTo(lista[z].nome) == 0){
                iguais++;
              }
            }
          }
          if(iguais == lista.length){
            instancias[i].item.quantidade++;
            existe = true;
          }
        } else {
          print("SEGUNDO ELSE");
          instancias.add(new InstanciaItem.create(ultimoIdInstancia, aux, lista));
          ultimoIdInstancia++;
          break;
        }
      }
      if(!existe){
        instancias.add(new InstanciaItem.create(ultimoIdInstancia, aux, lista));
        ultimoIdInstancia++;
      }
    } else {
      print("PRIMEIRO ELSE");
      instancias.add(new InstanciaItem.create(ultimoIdInstancia, aux, lista));
      ultimoIdInstancia++;
    }
  }

//Função para subtrair itens
  void subItem(List<Participante> lista, InstanciaItem instancia) {
    print("INSTANCIAS.LENGTH: ${instancia.participantes.length} - PARTICIPANTES.LENGTH: ${lista.length}");
    if(instancia.participantes.length == lista.length){
      if(instancia.item.quantidade > 1){
        instancia.item.quantidade--;
        itens[instancia.item.id].quantidade++;
        print("1");
      }
      else{
        instancias.remove(instancia);
        itens[instancia.item.id].quantidade++;
        print("2");
      }
    }
    else{
      Set<Participante> aux = lista.toSet();
      Set<Participante> auy = instancia.participantes.toSet();
      aux = auy.intersection(aux);
      auy = auy.difference(aux);
      if(instancia.item.quantidade > 1){
        instancia.item.quantidade--;
        Item auz = new Item.padrao(instancia.item.id,
            1,
            instancia.item.nome,
            (instancia.item.preco + (instancia.item.preco/auy.length)));
        instancias.add(new InstanciaItem.create(ultimoIdInstancia, auz, auy.toList()));
        ultimoIdInstancia++;
        print("3");
      }
      else{
        instancias.remove(instancia);
        Item auz = new Item.padrao(instancia.item.id,
            1,
            instancia.item.nome,
            (instancia.item.preco + (instancia.item.preco/lista.length)));
        instancias.add(new InstanciaItem.create(ultimoIdInstancia, auz, auy.toList()));
        ultimoIdInstancia++;
        print("4");
      }
    }
  }

  Scaffold iniciarTela() {
    String dropdownText = "Participantes Selecionados";
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
          )
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _scanner(context);
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
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  estado = 1;
                  instancias = [];
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

  Scaffold scanedScream() {
    String dropdownText = "Participantes Selecionados";
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
                        Text(
                          textAlign: TextAlign.center,
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
                              //aux.removeRange(0, aux.length);
                              qtd = itens[index].quantidade;
                              textoPadrao = "${item.nome}\nQuantidade - ${qtd}\nPreço - R\$${preco}";
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
                              List<Participante> lista = [];
                              for(int i = 0; i < selectedOptions.length; i++){
                                Participante auy = participantes[identificarParticipante(selectedOptions[i])];
                                lista.add(auy);
                              }
                              for(int i = 0; i < selectedOptions.length; i++) {
                                print("LISTA[${i}]: ${lista[i].nome}");
                              }
                              InstanciaItem ? instancia = identificarInstancia(itens[index], lista);
                              if(instancia != null) {
                                _removerDivisor(context, instancia);
                                //lista.removeRange(0, lista.length);
                                qtd = itens[index].quantidade;
                                textoPadrao = "${item.nome}\nQuantidade - ${qtd}\nPreço - R\$${preco}";
                              }
                              else{
                                print("INSTÂNCIA NÃO ENCONTRADA");
                              }
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
