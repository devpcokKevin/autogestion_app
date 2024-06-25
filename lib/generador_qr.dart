import 'package:autogestion/shared/appbar.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScreen extends StatefulWidget {
  final String appBarTitle;
  final IconData appBarIcon;

  const QrScreen({Key? key, required this.appBarTitle, required this.appBarIcon}) : super(key: key);

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final GlobalKey globalKey = GlobalKey();
  String qrData = "";

  // Variables para la información de la empresa y nombre con DNI
  String user_empresa = "INFORMATICA CONTABLE S.A.";
  String user_nombre = "Paolo Leon Antunez";
  String user_tipo = "Developer";
  String user_id = "73654";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: widget.appBarTitle,
        icon: widget.appBarIcon,
        implyLeading: false,
        marginLeft: 50.0, // Ajusta el margen según sea necesario
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),
            Text(
              user_empresa,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF023E73),
              ),
            ),
            SizedBox(height: 20),
            RepaintBoundary(
              key: globalKey,
              child: Container(
                child: Column(
                  children: [
                    Center(
                      child: QrImageView(
                        data: qrData.isNotEmpty ? qrData : "Default Data",
                        version: QrVersions.auto,
                        size: 250,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      user_nombre,
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Tipo: $user_tipo",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "ID: $user_id",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Acción del primer botón
                            print("Primer botón presionado");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF023E73), // Color de fondo del botón
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Descargar"),
                              SizedBox(width: 5), // Ajusta el espacio entre el texto y el icono
                              Icon(
                                Icons.download,
                                size: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Acción del primer botón
                            print("Primer botón presionado");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF023E73), // Color de fondo del botón
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Actualizar"),
                              SizedBox(width: 5), // Ajusta el espacio entre el texto y el icono
                              Icon(
                                Icons.cached,
                                size: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Enter Data",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    qrData = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
