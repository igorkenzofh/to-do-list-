import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// TODO 1: Importar material
// TODO 2: Criar main com maerial app e home
// TODO 3: criar stateful class Home
// TODO 4: Importar package https://pub.dev/packages/path_provider, colocar no yaml
// TODO 5: Construir Future e import dart.io DENTRO da classe Home
void main() {
  runApp(
    MaterialApp(
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // TODO 7: Criar uma lista
  List _toDoList = [];
  Map _lastRemoved;
  int _lastRemovedPos;

  // TODO 12: Criar controller https://flutter.dev/docs/cookbook/forms/retrieve-input
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  // TODO 13: Criar função para add a lista
  void _addToDo() {
    setState(() {
      // TODO 14: Colcoar o código em setstate para atualizar a listile
      Map<String, dynamic> newToDo = Map(); // Criar um Mapa
      newToDo['Title'] =
          myController.text; // Adicionar como titulo o texto do meu textfield
      myController.text = ''; // Limpar o textfield
      newToDo['Ok'] =
          false; // Declara que a tarefa recem criada nao foi cumprida
      _toDoList.add(newToDo); // Add a tarefa a lista
      _saveData();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(
      Duration(seconds: 1),
    );

    setState(() {
      _toDoList.sort((a, b) {
        if (a['Ok'] && !b['Ok'])
          return 1;
        else if (!a['Ok'] && b['Ok'])
          return -1;
        else
          return 0;
      });
      _saveData();
    });
    return null;
  }

  // TODO 11: Construir o Layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text('Lista de tarefas'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: myController,
                      decoration: InputDecoration(
                        labelText: 'Nova tarefa',
                        labelStyle: TextStyle(color: Colors.purple),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                        alignment: Alignment.bottomCenter,
                        iconSize: 40,
                        icon: Icon(Icons.add_circle_outline_outlined),
                        color: Colors.purple,
                        padding: EdgeInsets.only(top: 5),
                        onPressed: () {
                          _addToDo();
                        }),
                  )
                ],
              ),
            ),
            Expanded(
              // TODO 16: Faz a lista atualizar puxando ela para baixo
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                    itemCount: _toDoList.length,
                    itemBuilder: buildItem),
              ),
            ),
          ],
        ));
  }

  // TODO 15: Organizando o código, criando a função de remover
  Widget buildItem(context, index) {
    return Dismissible(
      // Key é uma string para identificar qual elemento é dismissible. Tem que ser unica para cada item
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
          alignment: Alignment(-0.9, 0),
        ),
      ),
      direction: DismissDirection.startToEnd,
      // no que eu vou dar dismissible? No check box
      child: CheckboxListTile(
        title: Text(_toDoList[index]['Title']),
        value: _toDoList[index]['Ok'],
        secondary: CircleAvatar(
            child: Icon(
          _toDoList[index]['Ok'] ? Icons.check : Icons.warning,
        )),
        onChanged: (c) {
          setState(() {
            _toDoList[index]['Ok'] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);

          _saveData();

          // Criando um Snackbar para confirmar a remoção de um item
          final snack = SnackBar(
            content: Text('Tarefa ${_lastRemoved['Title']} removida!'),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                // Função para desfazer
                setState(() {
                  _toDoList.insert(_lastRemovedPos, _lastRemoved);
                  _saveData();
                });
              },
            ),
            // Especificando a duração
            duration: Duration(seconds: 2),
          );
          // Configurando seu display, quando vai mostrar
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(
              snack); // Procura o 1o scaffold acima e envia um comando
        });
      },
    );
  }

  // FUNÇÃO PARA PEGAR ARQ
  Future<File> _getFile() async {
    // Usa async porque tem um await dentro
    final directory = await getApplicationDocumentsDirectory();
    return File(
        "${directory.path}/data.json"); // Pega o caminho do diretório, junta com data.json e abre (File) o arq
  }

// TODO 6: Criar função para pegar a lista, transformar em json e salvar em uma String, importar library convert
  // FUNÇÃO PARA SALVAR DADO NO ARQ
  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    // TODO 8: Pegar o arq, mas como é um valor futuro, bota o await
    final file = await _getFile();
    // TODO 9: Pega o arq que acabou de obter pelo getFile e escreve os dados como string
    return file.writeAsString(data);
  }

  // TODO 10: Criando função para ler os dados
  // FUNÇÃO PARA LER ARQ
  Future _readData() async {
    try {
      final file = await _getFile(); // tentando pegar nosso arq
      return file.readAsString(); // retornar o file como string
    } catch (e) {
      return null;
    }
  }
}
