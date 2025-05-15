import 'package:simplied_attendace/models/attendance_data.dart';

class AttendanceService {
  Future<void> sendAttendance(AttendanceData data) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    print("Attendance sent: ${data.name}");
  }
}
