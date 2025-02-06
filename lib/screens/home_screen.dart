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
      DateTime dataEntrega = DateFormat('dd/MM/yyyy HH:mm').parse('${tarefa['dataEntrega']} ${tarefa['horaEntrega']}');

      if (tarefa['status'] == 'pendente' && dataEntrega.difference(agora).inMinutes <= 30) {
        NotificationService.showNotification(
          "Tarefa Vencendo",
          "A tarefa '${tarefa['titulo']}' está prestes a vencer!",
        );
      }
    }
  }

  void _confirmarFinalizacaoTarefa(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Finalizar Tarefa"),
          content: Text("Tem certeza de que deseja marcar esta tarefa como finalizada?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _finalizarTarefa(id);
                Navigator.pop(context);
              },
              child: Text("Finalizar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _finalizarTarefa(int id) async {
    await _dbHelper.updateTaskStatus(id, 'finalizada');
    _loadTasks();
  }

  void _adicionarTarefa() {
    TextEditingController _tituloController = TextEditingController();
    TextEditingController _descricaoController = TextEditingController();
    DateTime? dataEntrega;
    TimeOfDay? horaEntrega;
    String prioridade = 'Média';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
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
                        setModalState(() {
                          dataEntrega = selectedDate;
                        });
                      }
                    },
                    child: Text(
                      dataEntrega == null ? "Selecionar Data" : DateFormat('dd/MM/yyyy').format(dataEntrega!),
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      TimeOfDay? selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        setModalState(() {
                          horaEntrega = selectedTime;
                        });
                      }
                    },
                    child: Text(
                      horaEntrega == null ? "Selecionar Hora" : "${horaEntrega!.hour}:${horaEntrega!.minute}",
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
                      setModalState(() {
                        prioridade = valor!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_tituloController.text.isNotEmpty &&
                          _descricaoController.text.isNotEmpty &&
                          dataEntrega != null &&
                          horaEntrega != null) {
                        await _dbHelper.addTask({
                          'titulo': _tituloController.text,
                          'descricao': _descricaoController.text,
                          'dataEntrega': DateFormat('dd/MM/yyyy').format(dataEntrega!),
                          'horaEntrega': "${horaEntrega!.hour}:${horaEntrega!.minute}",
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
      },
    );
  }

  List<Map<String, dynamic>> _filtrarTarefas() {
    if (filtroSelecionado == 'Pendentes') {
      return tarefas.where((t) => t['status'] == 'pendente').toList();
    } else if (filtroSelecionado == 'Finalizadas') {
      return tarefas.where((t) => t['status'] == 'finalizada').toList();
    }
    return tarefas;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> tarefasFiltradas = _filtrarTarefas();

    return Scaffold(
      appBar: AppBar(title: Text("Minhas Tarefas")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(onPressed: () => setState(() => filtroSelecionado = 'Todas'), child: Text("Todas")),
                ElevatedButton(onPressed: () => setState(() => filtroSelecionado = 'Pendentes'), child: Text("Pendentes")),
                ElevatedButton(onPressed: () => setState(() => filtroSelecionado = 'Finalizadas'), child: Text("Finalizadas")),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tarefasFiltradas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tarefasFiltradas[index]['titulo']),
                  subtitle: Text("Entrega: ${tarefasFiltradas[index]['dataEntrega']} às ${tarefasFiltradas[index]['horaEntrega']}"),
                  trailing: tarefasFiltradas[index]['status'] == 'pendente'
                      ? IconButton(icon: Icon(Icons.check_circle, color: Colors.green), onPressed: () => _confirmarFinalizacaoTarefa(tarefasFiltradas[index]['id']))
                      : Icon(Icons.check_circle, color: Colors.grey),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _adicionarTarefa, backgroundColor: Colors.blueAccent, child: Icon(Icons.add, color: Colors.white)),
    );
  }
}
