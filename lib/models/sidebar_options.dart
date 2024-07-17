import 'dart:io';
import 'dart:math';

import 'package:autogestion/screens/geocerca/geocerca_screen.dart';
import 'package:autogestion/screens/miHorario/mi_horario_screen.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Enviroment/Variables.dart';
import '../screens/home/inicio_screen.dart';
import '../screens/miPerfil/mi_perfil_screen.dart';
import '../screens/miQr/mi_qr_screen.dart';
import '../screens/qrScanner/scanner_screen.dart';
import '../src/login.dart';

class MenuOption {
  final IconData icon;
  final String title;
  final Widget? view;
  final Function()? onTap;

  MenuOption({
    required this.icon,
    required this.title,
    this.view,
    this.onTap
  });
}

List<MenuOption> sideMenus = [
  MenuOption(
    icon: Icons.home,
    title: "Inicio",
    view: InicioScreen(appBarTitle: "Inicio",
        appBarIcon: Icons
            .home),
  ),
  MenuOption(
    icon: Icons.person,
    title: "Mi Perfil",
    view: miPerfilScreen(
        appBarTitle: "Mi Perfil",
        appBarIcon: Icons
            .person), // Reemplaza con la vista correspondiente si es necesario
  ),
  MenuOption(
    icon: Icons.qr_code_scanner,
    title: "Mi QR",
    view: QrScreen(appBarTitle: "MI QR", appBarIcon: Icons.qr_code_scanner),
  ),
  MenuOption(
    icon: Icons.barcode_reader,
    title: "Escaner",
    view: QRScannerScreen(
        appBarTitle: "Escaner",
        appBarIcon: Icons
            .barcode_reader), // Reemplaza con la vista correspondiente si es necesario
  ),
];

List<MenuOption> sideMenu2 = [
  MenuOption(
    icon: Icons.calendar_month,
    title: "Mi Horario",
    view: miHorarioScreen(
        appBarTitle: "Mi Horario",
        appBarIcon: Icons
            .calendar_month), // Reemplaza con la vista correspondiente si es necesario
  ),
  MenuOption(
    icon: Icons.notifications,
    title: "Geocerca",
    view: GoogleMapScreen(
        appBarTitle: "Geocerca",
        appBarIcon: Icons
            .location_on), // Reemplaza con la vista correspondiente si es necesario
  ),
];

Future<void> clearSharedPreferences() async{
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}

// Nueva opción de "Salir"
MenuOption exitOption = MenuOption(
  icon: Icons.logout,
  title: "Salir",
  onTap:()async{

    var url = '$baseUrl/api/UsuarioL/cerrarSesion';
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var datosUsuario = sharedPreferences.getString("datosUsuario");
    print('datosUsuario: '+datosUsuario.toString());

    Dio dio = Dio();
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
    // dio.post(
    //   data: datosUsuario,
    //   url,
    //   options: Options(headers: {"Content-Type": "application/json"}),
    // ).then()

    await clearSharedPreferences();

  },
  view: LoginForm()
);
