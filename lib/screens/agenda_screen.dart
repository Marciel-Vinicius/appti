import 'package:flutter/material.dart';

class AgendaScreen extends StatefulWidget {
  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final TextEditingController tituloController = TextEditingController();
  DateTime? dataSelecionada;

  Future<void> selecionarData() async {
    DateTime? data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (data != null) {
      TimeOfDay? hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (hora != null) {
        setState(() {
          dataSelecionada = DateTime(
            data.year, data.month, data.day, hora.hour, hora.minute);
        });
      }
    }
  }

  void salvarAgendamento() {
    if (tituloController.text.isNotEmpty && dataSelecionada != null) {
      Navigator.pop(context, {
        'titulo': tituloController.text,
        'data': dataSelecionada.toString(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(title: Text("Agendar Tarefa"), backgroundColor: Colors.blueAccent),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: tituloController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Título",
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.black45,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: selecionarData,
              child: Text("Selecionar Data e Hora"),
            ),
            SizedBox(height: 10),
            Text(
              dataSelecionada != null
                  ? "Data selecionada: ${dataSelecionada.toString()}"
                  : "Nenhuma data selecionada",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: salvarAgendamento,
              child: Text("Salvar Agendamento"),
            ),
          ],
        ),
      ),
    );
  }
}
