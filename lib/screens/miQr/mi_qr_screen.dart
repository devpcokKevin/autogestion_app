import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:autogestion/shared/appbar.dart';

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

  String usuarioNombre = ""; // Variable para almacenar el nombre del usuario
  String usuarioCargo = "";
  String usuarioId = "";
  String razonSocial = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? razonSocialPref = prefs.getString('razon_social');
    if (razonSocialPref != null) {
      setState(() {
        razonSocial = razonSocialPref;
      });
    }
    String? datosUsuarioJson = prefs.getString('datosUsuario');
    if (datosUsuarioJson != null) {
      Map<String, dynamic> datosUsuario = jsonDecode(datosUsuarioJson);
      setState(() {
        usuarioNombre = datosUsuario['usuario_nombre'];
        usuarioCargo = datosUsuario['usuario_cargo'];
        usuarioId = datosUsuario['usuario_id'];
      });
    }
  }

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
              razonSocial,
              style: TextStyle(
                fontSize: 25,
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
                      usuarioNombre, // Reemplazado por la variable de SharedPreferences
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Cargo: $usuarioCargo",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "ID: $usuarioId",
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
                            // Acción del segundo botón
                            print("Segundo botón presionado");
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
                    qrData = "DIEGO QUEZADA";
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
