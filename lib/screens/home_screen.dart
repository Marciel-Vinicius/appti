import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class HomeScreen extends StatefulWidget {
  final String emailUsuario;

  HomeScreen({required this.emailUsuario});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> tarefas = [];
  String nomeUsuario = "";
  String setorUsuario = "";
  String filtroSelecionado = "Todas";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTasks();
  }

  void _loadUserData() async {
    var user = await _dbHelper.getUserByEmail(widget.emailUsuario);
    if (user != null) {
      setState(() {
        nomeUsuario = user['nomeCompleto'];
        setorUsuario = user['setor'];
      });
    }
  }

  void _loadTasks() async {
    List<Map<String, dynamic>> loadedTasks = await _dbHelper.getTasks();
    List<Map<String, dynamic>> tasksCopy = List<Map<String, dynamic>>.from(loadedTasks);

    if (filtroSelecionado == "Pendentes") {
      tasksCopy = tasksCopy.where((t) => t['status'] == 'pendente').toList();
    } else if (filtroSelecionado == "Finalizadas") {
      tasksCopy = tasksCopy.where((t) => t['status'] == 'finalizada').toList();
    }

    tasksCopy.sort((a, b) {
      const prioridadeOrdem = {"Alta": 1, "Média": 2, "Baixa": 3};
      return prioridadeOrdem[a['prioridade']]!.compareTo(prioridadeOrdem[b['prioridade']]!);
    });

    setState(() {
      tarefas = tasksCopy;
    });
  }

  Future<void> _finalizarTarefa(int id) async {
    bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Finalizar Tarefa"),
        content: Text("Tem certeza que deseja marcar esta tarefa como finalizada?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Finalizar", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirmar) {
      await _dbHelper.updateTaskStatus(id, "finalizada");
      _loadTasks();
    }
  }

  Color _corPrioridade(String prioridade) {
    switch (prioridade) {
      case "Alta":
        return Colors.redAccent;
      case "Média":
        return Colors.orangeAccent;
      case "Baixa":
        return Colors.greenAccent;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildTaskCard(Map<String, dynamic> tarefa) {
    return Card(
      color: Colors.grey[850],
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          width: 10,
          height: double.infinity,
          decoration: BoxDecoration(
            color: _corPrioridade(tarefa['prioridade']),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        title: Text(
          tarefa['titulo'],
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tarefa['descricao'], style: TextStyle(color: Colors.white70)),
            SizedBox(height: 5),
            Text(
              "Entrega: ${tarefa['dataEntrega']} às ${tarefa['horaEntrega']}",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            Text(
              "Prioridade: ${tarefa['prioridade']}",
              style: TextStyle(color: _corPrioridade(tarefa['prioridade']), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.yellow),
              onPressed: () {}, // Implementar edição depois
            ),
            IconButton(
              icon: Icon(Icons.check, color: Colors.green),
              onPressed: () => _finalizarTarefa(tarefa['id']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavbar() {
    return Container(
      color: Colors.blueGrey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ["Todas", "Pendentes", "Finalizadas"].map((filtro) {
          return GestureDetector(
            onTap: () {
              setState(() {
                filtroSelecionado = filtro;
              });
              _loadTasks();
            },
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                filtro,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: filtroSelecionado == filtro ? Colors.blueAccent : Colors.white70),
              ),
            ),
          );
        }).toList(),
      ),
    );
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
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Nova Tarefa", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 10),
              TextField(
                controller: _tituloController,
                decoration: InputDecoration(labelText: "Título", filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  DateTime? selectedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
                  if (selectedDate != null) {
                    setState(() {
                      dataEntrega = selectedDate;
                    });
                  }
                },
                child: Text(dataEntrega == null ? "Selecionar Data" : DateFormat('dd/MM/yyyy').format(dataEntrega!), style: TextStyle(color: Colors.blueAccent)),
              ),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? selectedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (selectedTime != null) {
                    setState(() {
                      horaEntrega = selectedTime;
                    });
                  }
                },
                child: Text(horaEntrega == null ? "Selecionar Hora" : "${horaEntrega!.hour}:${horaEntrega!.minute}", style: TextStyle(color: Colors.blueAccent)),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _dbHelper.addTask({'titulo': _tituloController.text, 'descricao': _descricaoController.text, 'dataEntrega': DateFormat('dd/MM/yyyy').format(dataEntrega!), 'horaEntrega': "${horaEntrega!.hour}:${horaEntrega!.minute}", 'prioridade': prioridade, 'status': 'pendente'});

                  _loadTasks();
                  Navigator.pop(context);
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
      body: Column(children: [_buildNavbar(), Expanded(child: ListView(children: tarefas.map((tarefa) => _buildTaskCard(tarefa)).toList()))]),
      floatingActionButton: FloatingActionButton(onPressed: _adicionarTarefa, backgroundColor: Colors.blueAccent, child: Icon(Icons.add, color: Colors.white)),
    );
  }
}
