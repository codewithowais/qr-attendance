#!/bin/bash

echo "🚀 Setting up Flutter QR Attendance App with Stacked MVVM Architecture..."

# Step 1: Create lib structure
mkdir -p lib/{app,models,services,theme,ui/{views/{login,home,camera},dialogs/student_confirmation}}

# Step 2: Write app.locator.dart
cat > lib/app/app.locator.dart << EOL
import 'package:get_it/get_it.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:attendance_app/services/attendance_service.dart';
import 'package:attendance_app/services/queue_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  // Services
  locator.registerLazySingleton(() => AttendanceService());
  locator.registerLazySingleton(() => QueueService());

  // Stacked Services
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
}
EOL

# Step 3: Write app.router.dart
cat > lib/app/app.router.dart << EOL
import 'package:auto_route/auto_route.dart';
import 'package:stacked_services/stacked_services.dart';

import '../ui/views/camera/camera_view.dart';
import '../ui/views/home/home_view.dart';
import '../ui/views/login/login_view.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'View,Route',
  routes: <AutoRoute>[
    AutoRoute(page: LoginView, initial: true),
    AutoRoute(page: HomeView),
    AutoRoute(page: CameraView),
  ],
)
class \$AppRouter {}

// Stacked Service Dialogs
final dialogService = DialogService();
EOL

# Step 4: Write attendance_data.dart
cat > lib/models/attendance_data.dart << EOL
import 'dart:convert';

class AttendanceData {
  final String studentId;
  final String name;
  final String branch;
  final String grade;
  final String profilePicUrl;
  final DateTime scannedAt;

  AttendanceData({
    required this.studentId,
    required this.name,
    required this.branch,
    required this.grade,
    required this.profilePicUrl,
    required this.scannedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'name': name,
      'branch': branch,
      'grade': grade,
      'profile_pic_url': profilePicUrl,
      'scanned_at': scannedAt.toIso8601String(),
    };
  }

  factory AttendanceData.fromMap(Map<String, dynamic> map) {
    return AttendanceData(
      studentId: map['student_id'],
      name: map['name'],
      branch: map['branch'],
      grade: map['grade'],
      profilePicUrl: map['profile_pic_url'],
      scannedAt: DateTime.parse(map['scanned_at']),
    );
  }
}
EOL

# Step 5: Write attendance_service.dart
cat > lib/services/attendance_service.dart << EOL
class AttendanceService {
  Future<void> sendAttendance(AttendanceData data) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    print("Attendance sent: \${data.name}");
  }
}
EOL

# Step 6: Write queue_service.dart
cat > lib/services/queue_service.dart << EOL
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:attendance_app/models/attendance_data.dart';

class QueueService {
  late Database _db;

  Future<void> init() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, "attendance_queue.db");

    _db = await openDatabase(path, version: 1, onCreate: (db, version) {
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
    });
  }

  Future<void> addToQueue(AttendanceData data) async {
    await _db.insert('AttendanceQueue', data.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AttendanceData>> getAllFromQueue() async {
    final List<Map<String, dynamic>> maps = await _db.query('AttendanceQueue');
    return List.generate(maps.length, (i) => AttendanceData.fromMap(maps[i]));
  }

  Future<void> removeFromQueue(String studentId) async {
    await _db.delete('AttendanceQueue', where: 'student_id = ?', whereArgs: [studentId]);
  }

  Future<void> clearQueue() async {
    await _db.delete('AttendanceQueue');
  }

  Future<void> processQueue(Function(AttendanceData) onSend) async {
    final items = await getAllFromQueue();
    for (var item in items) {
      try {
        await onSend(item);
        await removeFromQueue(item.studentId);
      } catch (e) {
        print("Failed to send: \$e");
        break; // Stop processing on error
      }
    }
  }
}
EOL

# Step 7: Write app_theme.dart
cat > lib/theme/app_theme.dart << EOL
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.indigo,
  );
}
EOL

# Step 8: Write home_view_model.dart
cat > lib/ui/views/home/home_view_model.dart << EOL
import 'package:stacked/stacked.dart';
import 'package:attendance_app/services/queue_service.dart';

class HomeViewModel extends ReactiveViewModel {
  final QueueService _queueService = locator<QueueService>();

  bool _darkMode = false;

  bool get darkMode => _darkMode;

  List<AttendanceData> get queue => _queueService.queueList;

  void toggleTheme() {
    _darkMode = !_darkMode;
    notifyListeners();
  }

  Future<void> clearQueue() async {
    await _queueService.clearQueue();
    notifyListeners();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_queueService];
}
EOL

# Step 9: Write camera_view_model.dart
cat > lib/ui/views/camera/camera_view_model.dart << EOL
import 'dart:convert';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:attendance_app/models/attendance_data.dart';
import 'package:attendance_app/services/queue_service.dart';
import 'package:attendance_app/services/attendance_service.dart';

class CameraViewModel extends BaseViewModel {
  final DialogService _dialogService = locator<DialogService>();
  final QueueService _queueService = locator<QueueService>();
  final AttendanceService _attendanceService = locator<AttendanceService>();

  Future<void> onScan(String qrCode) async {
    try {
      final json = jsonDecode(qrCode);
      final data = AttendanceData(
        studentId: json['id'],
        name: json['name'],
        branch: json['branch'],
        grade: json['grade'],
        profilePicUrl: json['pic'],
        scannedAt: DateTime.now(),
      );

      final result = await _dialogService.showCustomDialog(
        variant: 'student_confirmation',
        data: data,
      );

      if (result?.confirmed == true) {
        await _queueService.addToQueue(data);
      }
    } catch (e) {
      print("Invalid QR Code: \$e");
    }
  }

  Future<void> startBackgroundProcessing() async {
    await _queueService.processQueue(_attendanceService.sendAttendance);
  }
}
EOL

# Step 10: Write home_view.dart
cat > lib/ui/views/home/home_view.dart << EOL
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:attendance_app/theme/app_theme.dart';
import 'package:attendance_app/ui/views/camera/camera_view.dart';
import 'home_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text("Attendance Queue"),
          actions: [
            IconButton(
              icon: Icon(model.darkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                model.toggleTheme();
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: model.queue.length,
          itemBuilder: (context, index) {
            var item = model.queue[index];
            return ListTile(
              title: Text(item.name),
              subtitle: Text("\${item.branch} - \${item.grade}"),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/camera'),
          child: Icon(Icons.qr_code_scanner),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: model.clearQueue,
            icon: Icon(Icons.delete),
            label: Text("Clear Queue"),
          ),
        ),
      ),
      onModelReady: (model) {
        model.startBackgroundProcessing(); // Start background sync
      },
    );
  }
}
EOL

# Step 11: Write camera_view.dart
cat > lib/ui/views/camera/camera_view.dart << EOL
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stacked/stacked.dart';
import 'package:attendance_app/ui/views/camera/camera_view_model.dart';

class CameraView extends StatelessWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CameraViewModel>.reactive(
      viewModelBuilder: () => CameraViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(title: Text("Scan QR")),
        body: MobileScanner(
          controller: MobileScannerController(),
          onDetect: (barcode, args) {
            if (barcode.rawValue != null) {
              model.onScan(barcode.rawValue!);
              Navigator.pop(context); // Go back after scan
            }
          },
        ),
      ),
    );
  }
}
EOL

# Step 12: Write login_view.dart
cat > lib/ui/views/login/login_view.dart << EOL
import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          child: Text("Login"),
        ),
      ),
    );
  }
}
EOL

# Step 13: Write student_confirmation_dialog.dart
cat > lib/ui/dialogs/student_confirmation/student_confirmation_dialog.dart << EOL
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:attendance_app/models/attendance_data.dart';

class StudentConfirmationDialog extends StatefulWidget {
  final Function(DialogResponse<bool>) onResult;
  final AttendanceData data;

  const StudentConfirmationDialog({
    Key? key,
    required this.onResult,
    required this.data,
  }) : super(key: key);

  @override
  State<StudentConfirmationDialog> createState() => _StudentConfirmationDialogState();
}

class _StudentConfirmationDialogState extends State<StudentConfirmationDialog> {
  void confirm() {
    widget.onResult(DialogResponse(confirmed: true));
    Navigator.pop(context);
  }

  void cancel() {
    widget.onResult(DialogResponse(confirmed: false));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Confirm Attendance"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.data.profilePicUrl.isNotEmpty)
            Image.network(widget.data.profilePicUrl, height: 100),
          Text("Name: \${widget.data.name}"),
          Text("Branch: \${widget.data.branch}"),
          Text("Grade: \${widget.data.grade}"),
        ],
      ),
      actions: [
        TextButton(onPressed: cancel, child: Text("Cancel")),
        ElevatedButton(onPressed: confirm, child: Text("OK")),
      ],
    );
  }
}
EOL

# Step 14: Update pubspec.yaml
cat >> pubspec.yaml << EOL

dependencies:
  flutter:
    sdk: flutter
  stacked: ^2.5.0
  stacked_services: ^5.0.0
  mobile_scanner: ^3.1.1
  sqflite: ^2.2.8
  path_provider: ^2.1.1
  path: ^1.8.3
  auto_route: ^4.2.4

dev_dependencies:
  build_runner: ^2.4.0
  stacked_generator: ^1.0.1
  auto_route_generator: ^4.2.4
EOL

chmod +x setup_attendance_app.sh

echo "✅ Files created successfully!"
echo "👉 Now run: flutter pub get"
echo "👉 Then: flutter pub run build_runner build --delete-conflicting-outputs"