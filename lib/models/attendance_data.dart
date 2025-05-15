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
