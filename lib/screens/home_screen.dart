import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> tarefas = [];
  int _selectedIndex = 0; // Controla a navegação

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
  }

  void _adicionarTarefa() async {
    await _dbHelper.addTask({
      'titulo': 'Nova Tarefa',
      'descricao': 'Descrição da tarefa',
      'dataEntrega': '01/01/2025',
      'prioridade': 'Média',
    });
    _loadTasks();
  }

  void _alterarStatusTarefa(int index) async {
    String novoStatus = tarefas[index]['status'] == 'pendente' ? 'finalizada' : 'pendente';
    await _dbHelper.updateTaskStatus(tarefas[index]['id'], novoStatus);
    _loadTasks();
  }

  void _deletarTarefa(int index) async {
    await _dbHelper.deleteTask(tarefas[index]['id']);
    _loadTasks();
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.pushNamed(context, '/agenda');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Minhas Tarefas")),
      body: ListView.builder(
        itemCount: tarefas.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.grey[900],
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              title: Text(tarefas[index]['titulo'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text("Status: ${tarefas[index]['status']}", style: TextStyle(color: Colors.white70)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.check, color: Colors.green), onPressed: () => _alterarStatusTarefa(index)),
                  IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deletarTarefa(index)),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black87,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Tarefas"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Agenda"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarTarefa,
        child: Icon(Icons.add),
      ),
    );
  }
}
