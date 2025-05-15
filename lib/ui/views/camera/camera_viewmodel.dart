import 'dart:convert';

import 'package:simplied_attendace/app/app.locator.dart';
import 'package:simplied_attendace/models/attendance_data.dart';
import 'package:simplied_attendace/services/attendance_service.dart';
import 'package:simplied_attendace/services/queue_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

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
      print("Invalid QR Code: $e");
    }
  }

  Future<void> startBackgroundProcessing() async {
    await _queueService.processQueue(_attendanceService.sendAttendance);
  }
}
