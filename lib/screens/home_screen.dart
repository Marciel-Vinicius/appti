import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final String emailUsuario;

  HomeScreen({required this.emailUsuario});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> tarefas = [];
  String filtroSelecionado = "Todas";

  void _adicionarTarefa(String titulo, DateTime dataEntrega) {
    setState(() {
      tarefas.add({
        'titulo': titulo,
        'dataEntrega': dataEntrega,
        'finalizada': false,
      });
    });
  }

  void _confirmarFinalizacaoTarefa(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Finalizar Tarefa"),
          content: Text("Tem certeza que deseja marcar esta tarefa como finalizada?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                _finalizarTarefa(index);
                Navigator.pop(context);
              },
              child: Text("Finalizar"),
            ),
          ],
        );
      },
    );
  }

  void _finalizarTarefa(int index) {
    setState(() {
      tarefas[index]['finalizada'] = !tarefas[index]['finalizada'];
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> tarefasFiltradas = tarefas.where((tarefa) {
      if (filtroSelecionado == "Pendentes") return !tarefa['finalizada'];
      if (filtroSelecionado == "Finalizadas") return tarefa['finalizada'];
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Bem-vindo, ${widget.emailUsuario}"),
      ),
      body: Column(
        children: [
          _buildNavbar(),
          Expanded(
            child: ListView.builder(
              itemCount: tarefasFiltradas.length,
              itemBuilder: (context, index) {
                var tarefa = tarefasFiltradas[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(tarefa['titulo']),
                    subtitle: Text(
                      "Entrega: ${DateFormat('dd/MM/yyyy HH:mm').format(tarefa['dataEntrega'])}",
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        tarefa['finalizada'] ? Icons.check_circle : Icons.circle_outlined,
                        color: tarefa['finalizada'] ? Colors.green : Colors.grey,
                      ),
                      onPressed: () => _confirmarFinalizacaoTarefa(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoAdicionarTarefa(context),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavbar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavbarButton("Todas"),
          _buildNavbarButton("Pendentes"),
          _buildNavbarButton("Finalizadas"),
        ],
      ),
    );
  }

  Widget _buildNavbarButton(String texto) {
    bool selecionado = filtroSelecionado == texto;
    return GestureDetector(
      onTap: () {
        setState(() {
          filtroSelecionado = texto;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: selecionado ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: selecionado ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoAdicionarTarefa(BuildContext context) {
    TextEditingController tituloController = TextEditingController();
    DateTime? dataSelecionada;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Adicionar Tarefa"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                decoration: InputDecoration(labelText: "Título"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  DateTime? data = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (data != null) {
                    TimeOfDay? hora = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (hora != null) {
                      setState(() {
                        dataSelecionada = DateTime(
                          data.year,
                          data.month,
                          data.day,
                          hora.hour,
                          hora.minute,
                        );
                      });
                    }
                  }
                },
                child: Text("Selecionar Data e Hora"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (tituloController.text.isNotEmpty && dataSelecionada != null) {
                  _adicionarTarefa(tituloController.text, dataSelecionada!);
                  Navigator.pop(context);
                }
              },
              child: Text("Adicionar"),
            ),
          ],
        );
      },
    );
  }
}
