import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _tarefas = []; // Altera para map para incluir data e hora
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _caregarTarefas();
  }

  void _addTarefa() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _tarefas.add({
          'tarefa': _controller.text,
          'dataHora': DateTime.now().toString(), // Salva data e hora de criação
        });
        _controller.clear();
        _salvarTarefas();
      });
    }
  }

  void _caregarTarefas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tarefaJson = prefs.getString('tarefas');

    if (tarefaJson != null) {
      setState(() {
        _tarefas.addAll(List<Map<String, String>>.from(json.decode(tarefaJson)));
      });
    }
  }

  void _salvarTarefas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tarefaJson = json.encode(_tarefas);
    await prefs.setString('tarefas', tarefaJson);
  }

  void _removerTarefa(int index) {
    setState(() {
      _tarefas.removeAt(index);
      _salvarTarefas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 110, 255),
        foregroundColor: Colors.white,
        title: const Text('AGENDA DE ATIVIDADES'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                    labelText: 'Agendar atividade', border: OutlineInputBorder()),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor agendar atividade';
                  }

                  if (value.length < 3) {
                    return 'Digite pelo menos 3 caracteres';
                  }
                  return null;
                },
              ),
            ),
          ),
          InkWell(
            onTap: _addTarefa,
            child: Container(
              margin: const EdgeInsets.all(10),
              width: double.infinity,
              height: 40,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 0, 255, 17),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: const Center(
                  child: Text(
                'Adicionar',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tarefas.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://i.pinimg.com/736x/10/a2/97/10a29727f1b5983cb1fd2541b20f1a36.jpg'),
                    ),
                    title: Text(_tarefas[index]['tarefa'] ?? ''),
                    subtitle: Text('Criado em: ${_tarefas[index]['dataHora']}'), // Exibe data e hora
                    trailing: IconButton(
                      onPressed: () => _removerTarefa(index),
                      icon: const Icon(Icons.delete),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
