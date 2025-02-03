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
  bool _modoEdicao = false; // Indica se está editando

  @override
  void initState() {
    super.initState();

    // Verifica se há uma tarefa para edição
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _modoEdicao = true;
          _tituloController.text = args['titulo'];
          _descricaoController.text = args['descricao'];
          _dataEntrega = DateFormat('dd/MM/yyyy').parse(args['dataEntrega']);
          _prioridade = args['prioridade'];
        });
      }
    });
  }

  Future<void> _selecionarDataEntrega() async {
    DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataEntrega ?? DateTime.now(),
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
      appBar: AppBar(title: Text(_modoEdicao ? "Editar Chamado" : "Novo Chamado")),
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
            TextButton(
              onPressed: _selecionarDataEntrega,
              child: Text(_dataEntrega == null ? "Selecionar Data" : DateFormat('dd/MM/yyyy').format(_dataEntrega!)),
            ),
            DropdownButton<String>(
              value: _prioridade,
              dropdownColor: Colors.black87,
              items: ["Alta", "Média", "Baixa"].map((p) => DropdownMenuItem(value: p, child: Text(p, style: TextStyle(color: Colors.white)))).toList(),
              onChanged: (valor) => setState(() => _prioridade = valor!),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _salvarChamado, child: Text("Salvar")),
          ],
        ),
      ),
    );
  }
}