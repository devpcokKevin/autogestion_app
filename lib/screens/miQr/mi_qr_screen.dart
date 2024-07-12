import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:autogestion/shared/appbar.dart';
import '../../Enviroment/Variables.dart';

class QrScreen extends StatefulWidget {
  final String appBarTitle;
  final IconData appBarIcon;

  const QrScreen({Key? key, required this.appBarTitle, required this.appBarIcon}) : super(key: key);

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final GlobalKey globalKey = GlobalKey();

  // Variables para la información de la empresa y nombre con DNI
  String user_empresa = "INFORMATICA CONTABLE S.A.";
  String usuarioNombre = ""; // Variable para almacenar el nombre del usuario
  String usuarioCargo = "";
  String usuarioId = "";
  String razonSocial = "";
  String qrData = "";

  int scanValue=1;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? razonSocialPref = prefs.getString('razon_social');
    String tokenVerificador = prefs.getString("tokenVerificador")!;
    String? datosUsuarioJson = prefs.getString('datosUsuario');

    Map<String, dynamic> tokenMapId = JwtDecoder.decode(tokenVerificador);

    print('token XD: '+tokenMapId.toString());

    if (razonSocialPref != null) {
      setState(() {
        razonSocial = razonSocialPref;
      });
    }

    if (datosUsuarioJson != null) {
      Map<String, dynamic> datosUsuario = jsonDecode(datosUsuarioJson);

      setState(() {

        usuarioNombre = datosUsuario['usuario_nombre'];
        usuarioCargo = datosUsuario['usuario_cargo'];
        usuarioId = datosUsuario['usuario_id'];
        this.qrData = tokenVerificador;

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
        marginLeft: 50.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 120),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(8),
              child: Text(
                razonSocial,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF023E73),
                ),
              ),
            ),
            SizedBox(height: 20),
            RepaintBoundary(
              key: globalKey,
              child: Container(
                color: Colors.white, // Fondo azul claro para identificar
                padding: EdgeInsets.all(8),
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
                    Container(
                      color: Colors.green[100],
                      // Fondo verde claro para identificar
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            usuarioNombre,
                            // Reemplazado por la variable de SharedPreferences
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
                        ],
                      ),
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
                              SizedBox(width: 5),
                              // Ajusta el espacio entre el texto y el icono
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
                            Dio dio = new Dio();
                            var url = '$baseUrl/api/UsuarioL/renovarToken';
                            dio
                                .post(
                              data: url,
                              url,
                              options: Options(headers: {"Content-Type": "application/json"}),
                            )
                                .then(
                              (response) async {
                                print('SE LOGRO: ' + response.data.toString());
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                prefs.setString("tokenVerificador", response.data.toString());
                              },
                            ).catchError(
                              (error) {
                                if (error is DioError) {
                                  print('Error de red: ' + error.response.toString());
                                } else {
                                  print('Error: ' + error.toString());
                                }
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF023E73), // Color de fondo del botón
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Actualizar"),
                              SizedBox(width: 5),
                              // Ajusta el espacio entre el texto y el icono
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
            Container(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
