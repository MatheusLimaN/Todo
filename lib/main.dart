import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Todo list',
    home: MyHomePage(),
  ));
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseReference _messagesRef;
  TextEditingController todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messagesRef = FirebaseDatabase.instance.reference().child('messages');

    FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000);
  }

  _showDialogNew() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
            title: Text('Adicionar novo'),
            content: TextField(
              controller: todoController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'digite uma nova tarefa'),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    todoController.text = '';
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar')),
              TextButton(
                  onPressed: () {
                    _save();
                  },
                  child: Text('Cadastrar')),
            ]);
      },
    );
  }

  _showDialogUpdate(key, value) {
    todoController.text = value;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Text('Atualizar todo'),
          content: TextField(
            controller: todoController,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'digite a nova tarefa'),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  todoController.text = '';
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar')),
            TextButton(
                onPressed: () {
                  _update(key);
                },
                child: Text('Atualizar')),
          ],
        );
      },
    );
  }

  Future<void> _save() async {
    await _messagesRef.push().set({'todo': todoController.text, 'done': false});
    todoController.text = '';
    Navigator.of(context).pop();
  }

  Future<void> _update(key) async {
    await _messagesRef.child(key).update({'todo': todoController.text});
    todoController.text = '';
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo list'),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: FirebaseAnimatedList(
              query: _messagesRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return SizeTransition(
                  sizeFactor: animation,
                  child: ListTile(
                    leading: Checkbox(
                      value: snapshot.value['done'],
                      onChanged: (bool value) => _messagesRef
                          .child(snapshot.key)
                          .update({'done': value}),
                    ),
                    trailing: IconButton(
                      onPressed: () =>
                          _messagesRef.child(snapshot.key).remove(),
                      icon: const Icon(Icons.delete),
                    ),
                    title: Text(snapshot.value['todo']),
                    onTap: () {
                      _showDialogUpdate(snapshot.key, snapshot.value['todo']);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialogNew,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
