import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onModelReady: (model) {
        model.loadQueue();
      },
      builder:
          (context, model, child) => Scaffold(
            appBar: AppBar(
              title: Text("Attendance Queue"),
              actions: [
                IconButton(
                  icon: Icon(
                    model.darkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                  onPressed: () {
                    model.toggleTheme();
                  },
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: model.queue.length,
              itemBuilder: (context, index) {
                var item = model.queue[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text("${item.branch} - ${item.grade}"),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: model.goToCamera,
              child: Icon(Icons.qr_code_scanner),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: model.clearQueue,
                icon: Icon(Icons.delete),
                label: Text("Clear Queue"),
              ),
            ),
          ),
    );
  }
}
