import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simplied_attendace/models/attendance_data.dart';
import 'package:stacked/stacked.dart';

class QueueService with ReactiveServiceMixin {
  late Database _db;

  List<AttendanceData> _queueList = [];

  List<AttendanceData> get queueList => _queueList;

  QueueService() {
    init();
  }

  Future<void> init() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, "attendance_queue.db");

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE AttendanceQueue (
          student_id TEXT PRIMARY KEY,
          name TEXT,
          branch TEXT,
          grade TEXT,
          profile_pic_url TEXT,
          scanned_at TEXT
        )
      ''');
      },
    );

    await _refreshQueueList();
  }

  Future<void> addToQueue(AttendanceData data) async {
    await _db.insert(
      'AttendanceQueue',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _refreshQueueList();
  }

  Future<void> _refreshQueueList() async {
    final List<Map<String, dynamic>> maps = await _db.query('AttendanceQueue');
    _queueList = List.generate(
      maps.length,
      (i) => AttendanceData.fromMap(maps[i]),
    );
    notifyListeners(); // This triggers UI updates in ViewModels
  }

  Future<void> removeFromQueue(String studentId) async {
    await _db.delete(
      'AttendanceQueue',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
    await _refreshQueueList();
  }

  Future<void> clearQueue() async {
    await _db.delete('AttendanceQueue');
    await _refreshQueueList();
  }

  Future<List<AttendanceData>> getAllFromQueue() async {
    final List<Map<String, dynamic>> maps = await _db.query('AttendanceQueue');
    return List.generate(maps.length, (i) => AttendanceData.fromMap(maps[i]));
  }

  Future<void> processQueue(Function(AttendanceData) onSend) async {
    final items = await getAllFromQueue();
    for (var item in items) {
      try {
        await onSend(item);
        await removeFromQueue(item.studentId);
      } catch (e) {
        print("Failed to send: $e");
        break; // Stop processing on error
      }
    }
  }
}
