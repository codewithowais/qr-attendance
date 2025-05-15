import 'package:flutter/material.dart';
import 'package:simplied_attendace/app/app.dialogs.dart';
import 'package:simplied_attendace/app/app.locator.dart';
import 'package:simplied_attendace/app/app.router.dart';
import 'package:simplied_attendace/theme/app_theme.dart';
import 'package:stacked_services/stacked_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  registerCustomDialogUi();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Attendance',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      navigatorKey: StackedService.navigatorKey,
      onGenerateRoute: StackedRouter().onGenerateRoute,
    );
  }
}
