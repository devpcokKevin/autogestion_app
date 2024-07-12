import 'dart:ui';

import 'package:autogestion/entry_point.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/adapter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

import '../models/Login.dart';

import '../../Enviroment/Variables.dart';

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
  String _deviceIdentifier = '';

  // final String _phoneIdentifier = 'TE1A.220922.010'; // Reemplaza con tu identificador

  @override
  Widget build(BuildContext context) {
    TextEditingController controlerCodEmpresa = TextEditingController();
    TextEditingController controlerContraEmpresa = TextEditingController();
    TextEditingController controlerCodUsuario = TextEditingController();
    TextEditingController controlerContraUsuario = TextEditingController();

    Future<void> _getDeviceIdentifier() async {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String? identifier;
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        identifier = androidInfo.id; // Identificador único de Android
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        identifier = iosInfo.identifierForVendor; // Identificador único de iOS
      }
      if (identifier != null) {
        setState(() {
          _deviceIdentifier = identifier!;
        });
      }
    }

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
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
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
                    foregroundColor: Colors.white70,
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
                    Login login = Login(empresa_codigo: "20354561124", empresa_password: "123456jv", usuario_codigo: "73370279", usuario_password: "usuarioBDD");
                    //192.168.0.10
                    BaseOptions options = BaseOptions(
                      connectTimeout: 6000,
                      receiveTimeout: 6000,
                    );

                    var url = '$baseUrl/api/UsuarioL/iniciarSesion';
                    var dio = Dio(options);

                    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
                      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
                      return client;
                    };
                    try {
                      dio
                          .post(
                        data: login.toJson(),
                        url,
                        options: Options(headers: {"Content-Type": "application/json"}),
                      )
                          .then((rpta) async {
                        print('GAAAAAAAAAAAAAAAAA');
                        await _getDeviceIdentifier();
                        var datosUsuario = rpta.data['datosUsuario'];
                        var user_phone_id = datosUsuario['usuario_phone_id'];
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String datosUsuarioJson = jsonEncode(rpta.data['datosUsuario']);
                        await prefs.setString('razon_social', rpta.data['razonSocial']);
                        await prefs.setString('empresa_codigo', rpta.data['empresa_codigo']);
                        await prefs.setString('tokenVerificador', rpta.data['idToken']);
                        // await prefs.setString('empresa_codigo', rpta.data['empresaCodigo']);
                        await prefs.setString('datosUsuario', datosUsuarioJson);
                        await prefs.setString('token', rpta.data['captcha']);

                        print('user phone bdd' + user_phone_id);
                        print('user phone android' + _deviceIdentifier);
                        if ("TP1A.220905.001" == "TP1A.220905.001") {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString('token', rpta.data['captcha']);
                          await prefs.setString('razon_social', rpta.data['razonSocial']);
                          String datosUsuarioJson = jsonEncode(rpta.data['datosUsuario']);
                          await prefs.setString('datosUsuario', datosUsuarioJson);
                          String token = prefs.getString("token")!;
                          Navigator.push(context, MaterialPageRoute(builder: (context) => EntryPoint()));
                        } else {
                          Fluttertoast.showToast(
                            msg: "Dispositivo no habilitado",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                      }, onError: (error) {
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => EntryPoint()));
                        print("TERRIBLE ");

                        Fluttertoast.showToast(
                          msg: "ERRRO DE CONEXION: " + (error as DioError).response.toString(),
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      });
                    } catch (e) {
                      print('Error: $e');
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
