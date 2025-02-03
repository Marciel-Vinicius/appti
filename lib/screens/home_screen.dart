import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> tarefas = [];
  int _selectedIndex = 0;

  Future<void> adicionarOuEditarTarefa({Map<String, dynamic>? tarefa, int? index}) async {
    final resultado = await Navigator.pushNamed(
      context, 
      '/chamado', 
      arguments: tarefa, // Passa a tarefa para edição (ou null para nova)
    );

    if (resultado != null) {
      setState(() {
        if (index != null) {
          tarefas[index] = resultado as Map<String, dynamic>; // Atualiza a tarefa
        } else {
          tarefas.add({
            ...resultado as Map<String, dynamic>,
            'status': 'pendente', // Sempre começa como pendente
            'dataFinalizacao': null, // Inicialmente sem data de finalização
          });
        }
      });
    }
  }

  void alterarStatusTarefa(int index) {
    if (tarefas[index]['status'] == 'pendente') {
      // Pergunta se deseja finalizar a tarefa
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Finalizar Tarefa"),
            content: Text("Tem certeza que deseja finalizar esta tarefa?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    tarefas[index]['status'] = 'finalizada';
                    tarefas[index]['dataFinalizacao'] = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
                  });
                  Navigator.pop(context);
                },
                child: Text("Finalizar"),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        tarefas[index]['status'] = 'pendente';
        tarefas[index]['dataFinalizacao'] = null; // Remove a data de finalização ao reabrir a tarefa
      });
    }
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
                  if (tarefa['dataFinalizacao'] != null) // Exibe a data de finalização apenas se houver
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        "Finalizada em: ${tarefa['dataFinalizacao']}",
                        style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w500),
                      ),
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
              onTap: () => adicionarOuEditarTarefa(tarefa: tarefa, index: index), // Permite editar
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
        onPressed: () => adicionarOuEditarTarefa(), // Nova tarefa
        child: Icon(Icons.add),
      ),
    );
  }
}