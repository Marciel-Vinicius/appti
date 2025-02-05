import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> tarefas = [];
  String filtroSelecionado = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    List<Map<String, dynamic>> loadedTasks = await _dbHelper.getTasks();
    setState(() {
      tarefas = loadedTasks;
    });

    _verificarTarefasVencendo();
  }

  void _verificarTarefasVencendo() async {
    DateTime agora = DateTime.now();

    for (var tarefa in tarefas) {
      DateTime dataEntrega = DateFormat('dd/MM/yyyy').parse(tarefa['dataEntrega']);

      if (tarefa['status'] == 'pendente' && dataEntrega.difference(agora).inHours <= 2) {
        NotificationService.showNotification(
          "Tarefa Vencendo",
          "A tarefa '${tarefa['titulo']}' está prestes a vencer!",
        );
      }
    }
  }

  void _finalizarTarefa(int id) async {
    await _dbHelper.updateTaskStatus(id, 'finalizada');
    _loadTasks();
  }

  void _deletarTarefa(int id) async {
    await _dbHelper.deleteTask(id);
    _loadTasks();
  }

  void _editarTarefa(Map<String, dynamic> tarefa) {
    TextEditingController _tituloController = TextEditingController(text: tarefa['titulo']);
    TextEditingController _descricaoController = TextEditingController(text: tarefa['descricao']);
    DateTime? dataEntrega = DateFormat('dd/MM/yyyy').parse(tarefa['dataEntrega']);
    String prioridade = tarefa['prioridade'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Editar Tarefa", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 10),
              TextField(
                controller: _tituloController,
                decoration: InputDecoration(labelText: "Título", filled: true, fillColor: Colors.white10),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descricaoController,
                decoration: InputDecoration(labelText: "Descrição", filled: true, fillColor: Colors.white10),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: dataEntrega!,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      dataEntrega = selectedDate;
                    });
                  }
                },
                child: Text(
                  dataEntrega == null ? "Selecionar Data" : DateFormat('dd/MM/yyyy').format(dataEntrega!),
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
              DropdownButton<String>(
                value: prioridade,
                dropdownColor: Colors.black87,
                items: ["Alta", "Média", "Baixa"].map((p) {
                  return DropdownMenuItem(value: p, child: Text(p, style: TextStyle(color: Colors.white)));
                }).toList(),
                onChanged: (valor) {
                  setState(() {
                    prioridade = valor!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _dbHelper.updateTaskStatus(tarefa['id'], prioridade);
                  _loadTasks();
                  Navigator.pop(context);
                },
                child: Text("Salvar Alterações"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _adicionarTarefa() {
    TextEditingController _tituloController = TextEditingController();
    TextEditingController _descricaoController = TextEditingController();
    DateTime? dataEntrega;
    String prioridade = 'Média';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Nova Tarefa", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 10),
              TextField(
                controller: _tituloController,
                decoration: InputDecoration(labelText: "Título", filled: true, fillColor: Colors.white10),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descricaoController,
                decoration: InputDecoration(labelText: "Descrição", filled: true, fillColor: Colors.white10),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      dataEntrega = selectedDate;
                    });
                  }
                },
                child: Text(
                  dataEntrega == null ? "Selecionar Data" : DateFormat('dd/MM/yyyy').format(dataEntrega!),
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
              DropdownButton<String>(
                value: prioridade,
                dropdownColor: Colors.black87,
                items: ["Alta", "Média", "Baixa"].map((p) {
                  return DropdownMenuItem(value: p, child: Text(p, style: TextStyle(color: Colors.white)));
                }).toList(),
                onChanged: (valor) {
                  setState(() {
                    prioridade = valor!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_tituloController.text.isNotEmpty &&
                      _descricaoController.text.isNotEmpty &&
                      dataEntrega != null) {
                    await _dbHelper.addTask({
                      'titulo': _tituloController.text,
                      'descricao': _descricaoController.text,
                      'dataEntrega': DateFormat('dd/MM/yyyy').format(dataEntrega!),
                      'prioridade': prioridade,
                      'status': 'pendente',
                    });

                    _loadTasks();
                    Navigator.pop(context);
                  }
                },
                child: Text("Adicionar Tarefa"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Minhas Tarefas")),
      body: Column(
        children: [
          ToggleButtons(
            isSelected: [filtroSelecionado == 'Todas', filtroSelecionado == 'Pendentes', filtroSelecionado == 'Finalizadas'],
            children: [Text("Todas"), Text("Pendentes"), Text("Finalizadas")],
            onPressed: (int index) {
              setState(() {
                filtroSelecionado = ['Todas', 'Pendentes', 'Finalizadas'][index];
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tarefas[index]['titulo']),
                  trailing: IconButton(icon: Icon(Icons.check), onPressed: () => _finalizarTarefa(tarefas[index]['id'])),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _adicionarTarefa, child: Icon(Icons.add)),
    );
  }
}
