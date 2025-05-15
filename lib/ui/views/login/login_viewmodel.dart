import 'package:simplied_attendace/app/app.locator.dart';
import 'package:simplied_attendace/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class LoginViewmodel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  goToHome() {
    _navigationService.replaceWith(Routes.homeView);
  }

  goToCamera() {
    _navigationService.replaceWith(Routes.cameraView);
  }
}
