import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> tarefas = [];
  int _selectedIndex = 0;

  Future<void> adicionarTarefa() async {
    final resultado = await Navigator.pushNamed(context, '/chamado');
    if (resultado != null) {
      setState(() {
        tarefas.add({
          'titulo': (resultado as Map<String, dynamic>)['titulo'],
          'descricao': resultado['descricao'],
          'dataEntrega': resultado['dataEntrega'],
          'prioridade': resultado['prioridade'],
          'status': 'pendente',
        });
      });
    }
  }

  void alterarStatusTarefa(int index) {
    setState(() {
      tarefas[index]['status'] =
          tarefas[index]['status'] == 'pendente' ? 'finalizada' : 'pendente';
    });
  }

  List<Map<String, dynamic>> get tarefasFiltradas {
    if (_selectedIndex == 1) {
      return tarefas.where((tarefa) => tarefa['status'] == 'pendente').toList();
    } else if (_selectedIndex == 2) {
      return tarefas.where((tarefa) => tarefa['status'] == 'finalizada').toList();
    }
    return tarefas;
  }

  Color getCorPrioridade(String prioridade) {
    switch (prioridade) {
      case 'Alta':
        return Colors.redAccent;
      case 'Média':
        return Colors.orangeAccent;
      case 'Baixa':
        return Colors.greenAccent;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(title: Text("Minhas Tarefas")),
      body: ListView.builder(
        itemCount: tarefasFiltradas.length,
        itemBuilder: (context, index) {
          var tarefa = tarefasFiltradas[index];
          return Card(
            color: Colors.grey[900],
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              title: Text(
                tarefa['titulo'],
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tarefa['descricao'],
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Entrega: ${tarefa['dataEntrega']}",
                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        "Prioridade: ",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: getCorPrioridade(tarefa['prioridade']),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tarefa['prioridade'],
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  tarefa['status'] == 'pendente' ? Icons.check_circle_outline : Icons.check_circle,
                  color: tarefa['status'] == 'pendente' ? Colors.orange : Colors.green,
                ),
                onPressed: () => alterarStatusTarefa(index),
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
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Todas"),
          BottomNavigationBarItem(icon: Icon(Icons.pending), label: "Pendentes"),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: "Finalizadas"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: adicionarTarefa,
        child: Icon(Icons.add),
      ),
    );
  }
}
