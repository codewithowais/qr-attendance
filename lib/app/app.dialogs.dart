import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import '../app/app.locator.dart'; // if locator is needed
import '../models/attendance_data.dart';

void registerCustomDialogUi() {
  final dialogService = locator<DialogService>();

  final builders = {
    'student_confirmation': (
      BuildContext context,
      DialogRequest dialogRequest,
      Function(DialogResponse) completer,
    ) {
      final AttendanceData data = dialogRequest.data;

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Confirm Attendance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text("Name: ${data.name}"),
              Text("Grade: ${data.grade}"),
              Text("Branch: ${data.branch}"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 👈 closes dialog manually
                      completer(DialogResponse(confirmed: false));
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 👈 closes dialog manually
                      completer(DialogResponse(confirmed: true));
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  };

  dialogService.registerCustomDialogBuilders(builders);
}
