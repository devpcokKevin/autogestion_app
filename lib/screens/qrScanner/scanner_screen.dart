import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:autogestion/screens/qrScanner/qroverlay.dart';
import '../../shared/appbar.dart';
import 'package:autogestion/utils/constants.dart';

class QRScannerScreen extends StatefulWidget {
  final String appBarTitle;
  final IconData appBarIcon;

  const QRScannerScreen({Key? key, required this.appBarTitle, required this.appBarIcon}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isScanCompleted = false;
  bool isScanningEnabled = true;
  Timer? scanSuccessTimer;

  void closeScreen() {
    setState(() {
      isScanCompleted = false;
    });
  }

  void startScanSuccessTimer() {
    scanSuccessTimer = Timer(Duration(seconds: 1), () {
      setState(() {
        isScanCompleted = false;
        isScanningEnabled = true;
      });
    });
  }

  void showScanSuccessDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        Timer(Duration(seconds: 4), () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              Text(
                code,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> sendQrDataToServer(String qrCode) async {
    try {
      Dio dio = Dio();
      final response = await dio.post(
        'https://localhost:7259/api/Qr/QrFoto',
        data: {
          "trabajador_id": 20019,
          "empresa_codigo": "20354561124",
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );
      print(response.data[1]['rpta']);
    } catch (e) {
      print("Error al enviar los datos del QR: $e");
    }
  }

  @override
  void dispose() {
    scanSuccessTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColorLight,
      drawer: const Drawer(),
      appBar: CustomAppBar(
        title: widget.appBarTitle,
        icon: widget.appBarIcon,
        implyLeading: false,
        marginLeft: 50.0,
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Escanea el QR",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
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
                  Opacity(
                    opacity: isScanCompleted ? 0.2 : 1.0,
                    child: MobileScanner(
                      allowDuplicates: true,
                      onDetect: (barcode, args) {
                        if (!isScanCompleted && isScanningEnabled) {
                          String code = barcode.rawValue ?? '---';
                          setState(() {
                            isScanCompleted = true;
                            isScanningEnabled = false;
                          });

                          showScanSuccessDialog(code);
                          sendQrDataToServer(code);
                          startScanSuccessTimer();
                        }
                      },
                    ),
                  ),
                  Positioned.fill(
                    child: QRScannerOverlay(overlayColour: backgroundColorLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
