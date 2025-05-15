import 'package:simplied_attendace/app/app.locator.dart';
import 'package:simplied_attendace/app/app.router.dart';
import 'package:simplied_attendace/models/attendance_data.dart';
import 'package:simplied_attendace/services/queue_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart'; // ✅ This imports @observable

class HomeViewModel extends BaseViewModel {
  final QueueService _queueService = locator<QueueService>();
  final _navigationService = locator<NavigationService>();

  // @observable // ✅ Now recognized!
  bool _darkMode = false;

  bool get darkMode => _darkMode;

  List<AttendanceData> get queue => _queueService.queueList;

  void toggleTheme() {
    _darkMode = !_darkMode;
    notifyListeners(); // Triggers UI update
  }

  Future<void> clearQueue() async {
    await _queueService.clearQueue();
    // No need to notify here — QueueService already notifies listeners
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_queueService];

  goToCamera() {
    _navigationService.replaceWith(Routes.cameraView);
  }
}
