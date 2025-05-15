import 'package:simplied_attendace/services/attendance_service.dart';
import 'package:simplied_attendace/services/queue_service.dart';
import 'package:simplied_attendace/ui/views/camera/camera_view.dart';
import 'package:simplied_attendace/ui/views/home/home_view.dart';
import 'package:simplied_attendace/ui/views/login/login_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: LoginView, initial: true, path: '/'),
    MaterialRoute(page: HomeView, path: 'home'),
    MaterialRoute(page: CameraView, path: 'camera'),
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: AttendanceService),
    LazySingleton(classType: QueueService),
  ],
)
class App {}
