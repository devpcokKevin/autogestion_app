import 'dart:async';

import 'package:flutter/material.dart';
import 'package:autogestion/utils/constants.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:autogestion/screens/qr/qroverlay.dart';

import '../../shared/appbar.dart';

const bgColor = Color(0xffafafa);

class QRScanner extends StatefulWidget {
  final String appBarTitle;
  final IconData appBarIcon;

  const QRScanner({Key? key, required this.appBarTitle, required this.appBarIcon}) : super(key: key);

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool isScanCompleted = false;
  bool isScanningEnabled = true; // Controla si el escáner puede escanear nuevos códigos
  MobileScannerController controller = MobileScannerController();
  Timer? scanSuccessTimer;

  void closeScreen() {
    isScanCompleted = false;
  }

  void startScanSuccessTimer() {
    // Inicia un temporizador para restablecer isScanCompleted después de 2 segundos
    scanSuccessTimer = Timer(Duration(seconds: 1), () {
      setState(() {
        isScanCompleted = false;
        isScanningEnabled = true; // Habilita el escaneo nuevamente
      });
    });
  }

  void showScanSuccessSnackBar(String code) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('QR escaneado correctamente. Código: $code'),
        duration: Duration(seconds: 1), // Ajusta la duración según tu necesidad
      ),
    );
  }

  @override
  void dispose() {
    scanSuccessTimer?.cancel(); // Cancela el temporizador al desechar el widget
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
        marginLeft: 50.0, // Ajusta el margen según sea necesario
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
                    opacity: isScanCompleted ? 0.2 : 1.0, // Reducimos la opacidad cuando se muestra el check
                    child: MobileScanner(
                      allowDuplicates: true,
                      onDetect: (barcode, args) {
                        if (!isScanCompleted && isScanningEnabled) {
                          String code = barcode.rawValue ?? '---';
                          setState(() {
                            isScanCompleted = true;
                            isScanningEnabled = false; // Desactivamos el escaneo mientras se muestra el check
                          });

                          showScanSuccessSnackBar(code);
                          startScanSuccessTimer();
                        }
                      },
                    ),
                  ),
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 300),
                    opacity: isScanCompleted ? 1.0 : 0.0, // Hacemos visible el check solo cuando se completa el escaneo
                    child: Align(
                      alignment: Alignment.center,
                      key: UniqueKey(), // Asegura la animación cuando cambia el widget
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 200,
                      ),
                    ),
                  ),
                  const QRScannerOverlay(overlayColour: backgroundColorLight),
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "Desarrollado por Netcode",
                  style: TextStyle(
                    color:Colors.black87,
                    fontSize:16,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
