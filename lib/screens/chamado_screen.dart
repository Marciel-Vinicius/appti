import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChamadoScreen extends StatefulWidget {
  @override
  _ChamadoScreenState createState() => _ChamadoScreenState();
}

class _ChamadoScreenState extends State<ChamadoScreen> {
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  DateTime? _dataEntrega;
  String _prioridade = "Média";

  Future<void> _selecionarDataEntrega() async {
    DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataEntrega = dataSelecionada;
      });
    }
  }

  void _salvarChamado() {
    if (_tituloController.text.isEmpty || _descricaoController.text.isEmpty || _dataEntrega == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preencha todos os campos!"), backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.pop(context, {
      'titulo': _tituloController.text,
      'descricao': _descricaoController.text,
      'dataEntrega': DateFormat('dd/MM/yyyy').format(_dataEntrega!),
      'prioridade': _prioridade,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(title: Text("Novo Chamado")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
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
            Row(
              children: [
                Text("Entrega: ", style: TextStyle(color: Colors.white70)),
                TextButton(
                  onPressed: _selecionarDataEntrega,
                  child: Text(
                    _dataEntrega == null ? "Selecionar Data" : DateFormat('dd/MM/yyyy').format(_dataEntrega!),
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
            DropdownButton<String>(
              value: _prioridade,
              dropdownColor: Colors.black87,
              items: ["Alta", "Média", "Baixa"].map((String prioridade) {
                return DropdownMenuItem(value: prioridade, child: Text(prioridade, style: TextStyle(color: Colors.white)));
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  _prioridade = valor!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _salvarChamado, child: Text("Salvar")),
          ],
        ),
      ),
    );
  }
}
