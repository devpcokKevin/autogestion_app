import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../shared/appbar.dart';
import 'qroverlay.dart';
import 'package:autogestion/utils/constants.dart';

const bgColor = Color(0xffafafa);

class QRScannerScreen extends StatefulWidget {
  final String appBarTitle;
  final IconData appBarIcon;

  const QRScannerScreen({
    Key? key,
    required this.appBarTitle,
    required this.appBarIcon,
  }) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isScanCompleted = false;
  bool isScanningEnabled = true;
  MobileScannerController controller = MobileScannerController();
  Timer? scanSuccessTimer;

  @override
  void initState() {
    super.initState();
    requestCameraPermission();
  }

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

  void showScanSuccessDialog(String nombre, Uint8List? fotoBytes) {
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
                nombre,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              if (fotoBytes != null)
                Container(
                  width: 100,
                  height: 100,
                  child: Image.memory(fotoBytes, fit: BoxFit.cover),
                ),
              SizedBox(height: 16),
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 30,
              ),
            ],
          ),
        );
      },
    );

    // Show custom toast below the AlertDialog
    Future.delayed(Duration(milliseconds: 100), () {
      showCustomToast('Datos obtenidos correctamente');
    });
  }

  void showCustomToast(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.70, // Adjust the top position as needed
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);

    // Remove the toast after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Uint8List hexToBytes(String hex) {
    final buffer = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < hex.length; i += 2) {
      buffer[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return buffer;
  }

  Future<void> sendQrDataToServer(String qrCode) async {
    var dio = Dio();
    var url = 'http://10.143.0.33:7259/api/Qr/QrFoto';
    var data = {
      "trabajador_id": 20019,
      "empresa_codigo": "20354561124"
    };

    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        print('Response status: ${response.statusCode}');
        print('Response data: ${response.data}');

        var responseData = response.data;
        var item3 = responseData['item3'];
        var nombreCompleto = item3['trabajador_nombre_completo'];
        var fotoHex = item3['trabajador_foto'];
        var fotoBytes = hexToBytes(fotoHex);

        showScanSuccessDialog(nombreCompleto, fotoBytes);

        Fluttertoast.showToast(
          msg: 'Datos obtenidos correctamente',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (status.isGranted) {
        controller.start();
      } else {
        Fluttertoast.showToast(
          msg: 'Permiso de cámara denegado',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      controller.start();
    }
  }

  @override
  void dispose() {
    scanSuccessTimer?.cancel();
    controller.dispose();
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
                    child: ClipPath(
                      clipper: OverlayClipper(),
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.84, // Ajuste el ancho del escáner aquí
                          height: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20), // Añade los bordes circulares aquí
                            child: MobileScanner(
                              allowDuplicates: true,
                              controller: controller,
                              onDetect: (barcode, args) {
                                if (!isScanCompleted && isScanningEnabled) {
                                  String code = barcode.rawValue ?? '---';
                                  setState(() {
                                    isScanCompleted = true;
                                    isScanningEnabled = false;
                                  });

                                  sendQrDataToServer(code);
                                  startScanSuccessTimer();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const QRScannerOverlay(overlayColour: backgroundColorLight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
