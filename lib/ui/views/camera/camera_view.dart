import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:simplied_attendace/ui/views/camera/camera_viewmodel.dart';
import 'package:stacked/stacked.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CameraViewModel>.reactive(
      viewModelBuilder: () => CameraViewModel(),
      builder:
          (context, model, child) => WillPopScope(
            onWillPop: () async => true,
            child: Scaffold(
              appBar: AppBar(title: Text("Scan QR")),
              body: MobileScanner(
                controller: MobileScannerController(),
                onDetect: (capture) {
                  final barcode = capture.barcodes.first;
                  final value = barcode.rawValue;
                  if (value != null && !model.isBusy) {
                    model.setBusy(true);
                    model
                        .onScan(value)
                        .whenComplete(() => model.setBusy(false));
                  }
                },
              ),
            ),
          ),
    );
  }
}
