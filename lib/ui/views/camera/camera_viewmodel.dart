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
  final snack = locator<SnackbarService>();

  Future<void> onScan(String qrCode) async {
    try {
      final parts = qrCode.split('|');
      if (parts.length < 7) throw FormatException("Invalid QR format");

      final data = AttendanceData(
        studentId: parts[3],
        name: parts[4],
        branch: parts[1],
        grade: parts[2],
        profilePicUrl: "https://via.placeholder.com/150",
        scannedAt: DateTime.now(),
      );

      final result = await _dialogService.showCustomDialog(
        variant: 'student_confirmation',
        data: data,
      );

      if (result?.confirmed == true) {
        await _queueService.addToQueue(data);
        snack.showSnackbar(message: "${data.name} added to queue");
      }
    } catch (e) {
      print("Invalid QR Code: $e");
    }
  }

  Future<void> startBackgroundProcessing() async {
    await _queueService.processQueue(_attendanceService.sendAttendance);
  }
}
