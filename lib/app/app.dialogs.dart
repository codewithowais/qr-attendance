import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import '../app/app.locator.dart'; // if locator is needed
import '../models/attendance_data.dart';

void registerCustomDialogUi() {
  final dialogService = locator<DialogService>();

  dialogService.registerCustomDialogBuilders({
    'student_confirmation': (context, dialogRequest, completer) {
      final data = dialogRequest.data as AttendanceData;

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Confirm Attendance',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text("Name: ${data.name}"),
              Text("Grade: ${data.grade}"),
              Text("Branch: ${data.branch}"),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      completer(DialogResponse(confirmed: false));
                      Navigator.of(context).pop(); // ✅ closes dialog
                    },
                    child: Text("Cancel"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      completer(DialogResponse(confirmed: true));
                    },
                    child: Text("OK"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  });
}
