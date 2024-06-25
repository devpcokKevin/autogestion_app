import 'package:autogestion/entry_point.dart';
import 'package:flutter/material.dart';
import 'package:autogestion/screens/home/home_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Login.dart';
import 'package:autogestion/models/Login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:autogestion/components/side_menu.dart';
import 'package:dio/adapter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para usar jsonEncode
import 'dart:io';

import 'package:dio/dio.dart';

class LoginForm extends StatefulWidget {
  LoginForm({Key? key}) : super(key: key);

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  String _codigoEmpresa = "";
  String _contrasenaEmpresa = "";
  String _codigoUsuario = "";
  String _contrasenaUsuario = "";

  @override
  Widget build(BuildContext context) {
    TextEditingController controlerCodEmpresa = TextEditingController();
    TextEditingController controlerContraEmpresa = TextEditingController();
    TextEditingController controlerCodUsuario = TextEditingController();
    TextEditingController controlerContraUsuario = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 90.0),
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30.0),
              Container(
                width: 100.0, // Ancho deseado para la imagen
                height: 100.0, // Alto deseado para la imagen
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    fit: BoxFit.cover, // Ajusta la imagen dentro del contenedor
                    image: AssetImage('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Autogestión',
                style: TextStyle(
                  fontFamily: 'Montserrat-SemiBold',
                  fontSize: 40.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF023E73),
                ),
              ),
              Text(
                'Inicio de Sesión',
                style: TextStyle(
                  fontFamily: 'Montserrat-Medium',
                  fontSize: 20.0,
                  color: Color(0xFF023E73),
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: controlerCodEmpresa,
                decoration: InputDecoration(
                  hintText: 'Código Empresa',
                  labelText: 'Código Empresa',
                  suffixIcon: Icon(Icons.verified_user),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                onSubmitted: (valor) {
                  _codigoEmpresa = valor;
                  print('El codigo de empresa es $_codigoEmpresa');
                },
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: controlerContraEmpresa,
                enableInteractiveSelection: false,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Contraseña Empresa',
                  labelText: 'Contraseña Empresa',
                  suffixIcon: Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                onSubmitted: (valor) {
                  _contrasenaEmpresa = valor;
                  print('La contraseña de la empresa es $_contrasenaEmpresa');
                },
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: controlerCodUsuario,
                decoration: InputDecoration(
                  hintText: 'Código Usuario',
                  labelText: 'Código Usuario',
                  suffixIcon: Icon(Icons.verified_user),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                onSubmitted: (valor) {
                  _codigoUsuario = valor;
                  print('el codigo de usuario es $_codigoUsuario');
                },
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: controlerContraUsuario,
                enableInteractiveSelection: false,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Contraseña Usuario',
                  labelText: 'Contraseña Usuario',
                  suffixIcon: Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                onSubmitted: (valor) {
                  _contrasenaUsuario = valor;
                  print('La contraseña del usuario es $_contrasenaUsuario');
                },
              ),
              SizedBox(height: 18.0),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF023E73),
                    foregroundColor: Colors.white70, // Color del texto
                  ),
                  child: Text(
                    'INGRESAR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20.0,
                      fontFamily: 'Montserrat-Medium',
                    ),
                  ),
                  onPressed: () async {
                    Login login = Login(
                      empresa_codigo: "20354561124",
                      empresa_password: "123456jv",
                      usuario_codigo: "73370279",
                      usuario_password: "usuarioBDD",
                      tipo_de_cambio: "3.70",
                      fecha_de_proceso: "21/06/2024",
                    );

                    var url =
                        'https://10.0.2.2:7259/api/UsuarioL/iniciarSesion';
                    BaseOptions options = BaseOptions(
                      connectTimeout: 1000,
                      // Timeout para la conexión en milisegundos
                      receiveTimeout: 1000,
                    );
                    Dio dio = Dio(options);
                    // Configurar HttpClientAdapter para aceptar todos los certificados (INSEGURO)
                    (dio.httpClientAdapter as DefaultHttpClientAdapter)
                        .onHttpClientCreate = (client) {
                      client.badCertificateCallback =
                          (X509Certificate cert, String host, int port) => true;
                      return client;
                    };

                    try {
                      var response = await dio
                          .post(
                        data: login.toJson(),
                        url,
                        options: Options(
                            headers: {"Content-Type": "application/json"}),
                      )
                          .then((rpta) async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();


                        await prefs.setString('token', rpta.data['captcha']);

                        await prefs.setString('razon_social', rpta.data['razonSocial']);

                        // Convertir datosUsuario a JSON y guardarlo
                        String datosUsuarioJson = jsonEncode(rpta.data['datosUsuario']);
                        await prefs.setString('datosUsuario', datosUsuarioJson);

                        String token = prefs.getString("token")!;
                        JwtDecoder.decode(token);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EntryPoint()));
                      }, onError: (error) {
                        Fluttertoast.showToast(
                          msg: "Error: " + (error as DioError).message,
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      });
                    } catch (error) {
                      if (error is DioError) {
                        Fluttertoast.showToast(
                          msg: "No se pudo conectar al servidor",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: "Error: " + "sintaxis",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
