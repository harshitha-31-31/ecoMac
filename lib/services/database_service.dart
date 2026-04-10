import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/message.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._init();

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chat_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        text TEXT NOT NULL,
        is_user INTEGER NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  // Insert a message
  Future<void> insertMessage(Message message) async {
    final db = await database;
    await db.insert(
      'messages',
      {
        'id': message.id,
        'text': message.text,
        'is_user': message.isUser ? 1 : 0,
        'timestamp': message.timestamp.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all messages
  Future<List<Message>> getAllMessages() async {
    final db = await database;
    final result = await db.query('messages', orderBy: 'timestamp ASC');

    return result.map((map) => Message(
          id: map['id'] as String,
          text: map['text'] as String,
          isUser: (map['is_user'] as int) == 1,
          timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        )).toList();
  }

  // Delete all messages
  Future<void> deleteAllMessages() async {
    final db = await database;
    await db.delete('messages');
  }

  // Export messages as formatted text
  Future<String> exportToText() async {
    final messages = await getAllMessages();
    final buffer = StringBuffer();

    buffer.writeln('=== Ecomac AI Chat Export ===');
    buffer.writeln('Exported on: ${DateTime.now().toString()}');
    buffer.writeln('Total Messages: ${messages.length}');
    buffer.writeln('=' * 30);
    buffer.writeln();

    for (final message in messages) {
      final sender = message.isUser ? 'You' : 'Ecomac AI';
      final time = '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}';
      buffer.writeln('[$time] $sender:');
      buffer.writeln(message.text);
      buffer.writeln();
    }

    return buffer.toString();
  }

  // Export as CSV
  Future<String> exportToCSV() async {
    final messages = await getAllMessages();
    final buffer = StringBuffer();

    buffer.writeln('Timestamp,Sender,Message');

    for (final message in messages) {
      final sender = message.isUser ? 'User' : 'AI';
      final escapedText = message.text.replaceAll('"', '""').replaceAll('\n', ' ');
      buffer.writeln(
        '"${message.timestamp.toString()}","$sender","$escapedText"',
      );
    }

    return buffer.toString();
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
