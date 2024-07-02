import 'package:autogestion/screens/geocerca/geocerca_screen.dart';
import 'package:flutter/material.dart';
import '../screens/home/inicio_screen.dart';
import '../screens/miPerfil/mi_perfil_screen.dart';
import '../screens/miQr/mi_qr_screen.dart';
import '../screens/qrScanner/scanner_screen.dart';
import '../src/login.dart';

class MenuOption {
  final IconData icon;
  final String title;
  final Widget? view;

  MenuOption({
    required this.icon,
    required this.title,
    this.view,
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
    title: "Scanner",
    view: QRScannerScreen(
        appBarTitle: "Scanner",
        appBarIcon: Icons
            .barcode_reader), // Reemplaza con la vista correspondiente si es necesario
  ),
];

List<MenuOption> sideMenu2 = [
  MenuOption(
    icon: Icons.calendar_month,
    title: "Mi Horario",
    view: QRScannerScreen(
        appBarTitle: "Mi Horario",
        appBarIcon: Icons
            .calendar_month), // Reemplaza con la vista correspondiente si es necesario
  ),
  MenuOption(
    icon: Icons.notifications,
    title: "Geocerca",
    view: GoogleMapScreen(
        appBarTitle: "Mapa",
        appBarIcon: Icons
            .location_on), // Reemplaza con la vista correspondiente si es necesario
  ),
];

// Nueva opción de "Salir"
MenuOption exitOption = MenuOption(
  icon: Icons.logout,
  title: "Salir",
  view: LoginForm(), // Reemplaza con la vista correspondiente si es necesario
);
