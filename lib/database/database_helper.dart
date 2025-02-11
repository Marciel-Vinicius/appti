import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'app_database.db');
      print("📁 Caminho do banco de dados: $path");

      return await openDatabase(
        path,
        version: 8, // Atualize a versão ao modificar a estrutura do banco
        onCreate: (db, version) async {
          print("🔹 Criando tabelas...");
          await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nomeCompleto TEXT,
              setor TEXT,
              email TEXT UNIQUE,
              password TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE tasks (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              titulo TEXT,
              descricao TEXT,
              dataEntrega TEXT,
              horaEntrega TEXT,
              prioridade TEXT,
              status TEXT DEFAULT 'pendente',
              finalizadaEm TEXT
            )
          ''');
          print("✅ Banco de dados criado com sucesso!");
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 8) {
            print("🔄 Atualizando banco de dados para versão $newVersion...");
            await db.execute("ALTER TABLE users ADD COLUMN nomeCompleto TEXT");
            await db.execute("ALTER TABLE users ADD COLUMN setor TEXT");
            print("✅ Atualização concluída.");
          }
        },
      );
    } catch (e) {
      print("❌ Erro ao inicializar o banco de dados: $e");
      rethrow;
    }
  }

  // 🔹 Função para registrar um usuário no banco de dados
  Future<int> registerUser(String nomeCompleto, String setor, String email, String password) async {
    try {
      final db = await database;
      int result = await db.insert('users', {
        'nomeCompleto': nomeCompleto,
        'setor': setor,
        'email': email,
        'password': password,
      });
      print("✅ Usuário cadastrado com sucesso! ID: $result");
      return result;
    } catch (e) {
      print("❌ Erro ao registrar usuário: $e");
      return -1;
    }
  }

  // 🔹 Função para buscar um usuário no banco de dados (autenticação)
  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    print(result.isNotEmpty ? "✅ Usuário encontrado: ${result.first}" : "❌ Usuário não encontrado.");
    return result.isNotEmpty ? result.first : null;
  }

  // 🔹 Função para buscar um usuário pelo e-mail
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // 🔹 Função para adicionar uma nova tarefa ao banco de dados
  Future<int> addTask(Map<String, dynamic> task) async {
    try {
      final db = await database;
      int result = await db.insert('tasks', task);
      print("✅ Tarefa adicionada com sucesso! ID: $result");
      return result;
    } catch (e) {
      print("❌ Erro ao adicionar tarefa: $e");
      return -1;
    }
  }

  // 🔹 Função para obter todas as tarefas do banco de dados
  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query('tasks');
    print("📌 Tarefas carregadas: $result");
    return result;
  }

  // 🔹 Função para atualizar o status de uma tarefa (pendente ou finalizada)
  Future<int> updateTaskStatus(int id, String newStatus) async {
    try {
      final db = await database;
      String finalizadaEm = newStatus == 'finalizada' ? DateTime.now().toString() : "";
      int result = await db.update(
        'tasks',
        {'status': newStatus, 'finalizadaEm': finalizadaEm},
        where: 'id = ?',
        whereArgs: [id],
      );
      print("✅ Status da tarefa atualizado! ID: $id, Novo Status: $newStatus");
      return result;
    } catch (e) {
      print("❌ Erro ao atualizar status da tarefa: $e");
      return -1;
    }
  }
}
