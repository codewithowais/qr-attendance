import 'package:flutter/material.dart';
import 'package:simplied_attendace/models/attendance_data.dart';
import 'package:stacked_services/stacked_services.dart';

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
          Text("Name: ${widget.data.name}"),
          Text("Branch: ${widget.data.branch}"),
          Text("Grade: ${widget.data.grade}"),
        ],
      ),
      actions: [
        TextButton(onPressed: cancel, child: Text("Cancel")),
        ElevatedButton(onPressed: confirm, child: Text("OK")),
      ],
    );
  }
}
