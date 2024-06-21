import 'dart:ui';

import 'package:autogestion/screens/qr/result_scanner.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:autogestion/screens/qr/overlay.dart';

const bgColor = Color(0xffafafa);

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool isScanCompleted = false;
  bool isFlashOn = false;
  bool isFrontCamera = false;
  MobileScannerController controller = MobileScannerController();

  void closeScreen() {
    isScanCompleted = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: const Drawer(),
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  isFlashOn = !isFlashOn;
                });
                controller.toggleTorch();
              },
              icon: Icon(Icons.flash_on, color: isFlashOn ? Colors.blue : Colors.grey)),
          IconButton(
              onPressed: () {
                setState(() {
                  isFrontCamera = !isFrontCamera;
                });
                controller.switchCamera();
              },
              icon: Icon(Icons.camera_front, color: isFrontCamera ? Colors.blue : Colors.grey)),
        ],
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Escanea el QR",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Text("El escaneo comenzará automáticamente"),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                    MobileScanner(
                      allowDuplicates: true,
                      onDetect: (barcode, args) {
                        if (!isScanCompleted) {
                          String code = barcode.rawValue ?? '---';
                          isScanCompleted = true;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ResultScreen(
                                    closeScreen: closeScreen,
                                    code: code,
                                  )));
                        }
                      },
                    ),
                    const QRScannerOverlay(overlayColour: bgColor),
                  ],
                )),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "Desarrollado por Netcode",
                  style: TextStyle(
                    color:Colors.black87,
                    fontSize:18,
                    fontWeight:FontWeight.bold,
                    letterSpacing: 1,
                  ),
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
