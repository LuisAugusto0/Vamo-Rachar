import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'novo_rachamento_scanned.dart';
import 'novo_rachamento.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/*void main() async {
  runApp(Scanner());
}*/

class Scanner extends StatelessWidget {
  final List<Participante> participantes;
  final List<Item> itens;
  int ultimoIdUsado;
  int ultimoIdItem;

  Scanner(
      {Key? key,
      required this.participantes,
      required this.itens,
      required this.ultimoIdUsado,
      required this.ultimoIdItem});

  @override
  Widget build(BuildContext context) {
    return ScannerScreen(
        participantes: participantes,
        itens: itens,
        ultimoIdUsado: ultimoIdUsado,
        ultimoIdItem: ultimoIdItem);
  }
}

class ScannerScreen extends StatefulWidget {
  final List<Participante> participantes;
  final List<Item> itens;
  int ultimoIdUsado;
  int ultimoIdItem;
  ScannerScreen(
      {Key? key,
      required this.participantes,
      required this.itens,
      required this.ultimoIdUsado,
      required this.ultimoIdItem});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState(
      itens: itens,
      participantes: participantes,
      ultimoIdUsado: ultimoIdUsado,
      ultimoIdItem: ultimoIdItem);
}

class _ScannerScreenState extends State<ScannerScreen> {
  File? _selectedImage;

  final List<Participante> participantes;
  final List<Item> itens;
  int ultimoIdUsado;
  int ultimoIdItem;

  _ScannerScreenState(
      {Key? key,
      required this.participantes,
      required this.itens,
      required this.ultimoIdUsado,
      required this.ultimoIdItem});

  // Função para selecionar uma imagem da galeria ou tirar uma foto
  Future<void> _chooseImageSource() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () async {
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Câmera'),
                onTap: () async {
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //Função que cria os intens com as informações extraídas pela IA
  void buildingItens(String? arrayProdutos) {
    if (arrayProdutos == null) {
      debugPrint("Erro ao ler os produtos");
      return;
    }
    if (arrayProdutos != "" && arrayProdutos != " " && arrayProdutos != null) {
      List<String> produtos = arrayProdutos.split(":");
      for (int i = 0; i < produtos.length; i++) {
        List<String> produto = produtos[i].split(";");
        for (int j = 0; j < produto.length; j++) {
          debugPrint("O que tem em produto[${j}]: ${produto[j]}");
        }
        if (produto.length == 3) {
          String nome = produto[0];
          int quantidade = int.parse(produto[1]);
          double? preco = double.tryParse(produto[2]);
          if (preco != null) {
            Item item = Item.padrao(ultimoIdItem, quantidade, nome, preco);
            if(!jaExiste(item)){
              itens.add(item);
              ultimoIdItem++;
            }
          } else {
            debugPrint("Erro ao converter o preço para double");
            preco = 0.0;
            Item item = Item.padrao(ultimoIdItem, quantidade, nome, preco);
            if(!jaExiste(item)){
              itens.add(item);
              ultimoIdItem++;
            }
          }
        } else {
          debugPrint("Erro ao ler o produto");
        }
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NovoRachamentoScanner(
              participantes: participantes,
              itens: itens,
              ultimoIdUsado: ultimoIdUsado)),
    );
  }

  //Função auxiliar que confirma itens duplicados
  bool jaExiste(Item item){
    bool existe = false;
    for(int i = 0; i < itens.length; i++){
      if(item.nome == itens[i].nome && item.preco == itens[i].preco){
        existe = true;
      }
    }

    return existe;
  }

  // Função para enviar a imagem para a IA;
  Future<void> _sendImageToAI() async {
    if (_selectedImage == null) {
      return;
    }

    final apiKey = dotenv.env['GEMINI_API_KEY']!;
    if (apiKey.isEmpty) {
      print('No \$API_KEY environment variable');
      exit(1);
    }

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    final image = await _selectedImage!.readAsBytes();
    final prompt = TextPart(
        "Transcreva a nota fiscal, listando todos os produtos, seus respectivos preços (separar a parte inteira da decimal por ponto) e a quantidade individual de cada produto, separe cada atributo do item por ';' para que possamos usar a função split para separar as informações. Todos os produtos devem estar em uma única linha e cada item encontrado deve estar separado por ':' em uma única linha, para que possamos separar os diferentes itens utilizando split também. Caso a quantidade seja um valor decimal, considere o valor inteiro do teto. Siga o seguinte modelo para cada produto: Nome1;Quantidade1;Preço1:Nome2;Quantidade2;Preço2, apenas respostas sem comentários do GEMINI AI por favor");

    final imageParts = [DataPart('image/jpeg', image)];
    final response = await model.generateContent([
      Content.multi([prompt, ...imageParts])
    ]);
    String? produtos = "";
    produtos = response.text;
    debugPrint("Instancia de produtos: ${produtos}");
    buildingItens(produtos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 1150,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _selectedImage == null
                    ? const Text('Nenhuma imagem selecionada.')
                    : Image.file(_selectedImage!,
                    width: 400,
                    height: 900,
                    fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _chooseImageSource,
                  child: const Text(
                    'Selecionar/Tirar Foto',
                    style: TextStyle(
                      color: Colors.green,
                    ),

                    ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sendImageToAI,
                  child: const Text(
                    'Enviar para análise',
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}
