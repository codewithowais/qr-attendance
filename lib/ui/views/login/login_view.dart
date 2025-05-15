import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'login_viewmodel.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewmodel>.reactive(
      viewModelBuilder: () => LoginViewmodel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(title: Text("Login")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: model.goToHome,
                child: Text("Go to Home"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: model.goToCamera,
                child: Text("Go to Camera"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
