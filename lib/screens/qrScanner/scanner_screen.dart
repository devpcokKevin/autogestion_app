import 'dart:async';
import 'package:flutter/material.dart';
import 'package:autogestion/utils/constants.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:autogestion/screens/qrScanner/qroverlay.dart';
import '../../shared/appbar.dart';

const bgColor = Color(0xffafafa);

class QRScannerScreen extends StatefulWidget {
  final String appBarTitle;
  final IconData appBarIcon;

  const QRScannerScreen({Key? key, required this.appBarTitle, required this.appBarIcon}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScannerScreen> {
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

  void showScanSuccessDialog(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              'https://via.placeholder.com/150', // URL de ejemplo para la imagen del QR
              width: 100,
              height: 100,
            ),
            SizedBox(height: 16),
            Text(
              code, // Aquí mostramos el código escaneado
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                isScanningEnabled = true;
              });
            },
            child: Text('Aceptar'),
          ),
        ],
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
                            isScanningEnabled = false; // Desactivamos el escaneo mientras se muestra el modal
                          });

                          showScanSuccessDialog(code);
                          startScanSuccessTimer();
                        }
                      },
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
