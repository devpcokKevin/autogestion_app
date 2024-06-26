import 'package:flutter/material.dart';

import '../generador_qr.dart';
import '../screens/qr/qrScanner.dart';
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
    view: LoginForm(),
  ),
  MenuOption(
    icon: Icons.person,
    title: "Mi Perfil",
    view: QRScanner(
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
    view: QRScanner(
        appBarTitle: "Scanner",
        appBarIcon: Icons
            .barcode_reader), // Reemplaza con la vista correspondiente si es necesario
  ),
];

List<MenuOption> sideMenu2 = [
  MenuOption(
    icon: Icons.calendar_month,
    title: "Mi Horario",
    view: QRScanner(
        appBarTitle: "Mi Horario",
        appBarIcon: Icons
            .calendar_month), // Reemplaza con la vista correspondiente si es necesario
  ),
  MenuOption(
    icon: Icons.notifications,
    title: "Notificaciones",
    view: QRScanner(
        appBarTitle: "Scanner",
        appBarIcon: Icons
            .barcode_reader), // Reemplaza con la vista correspondiente si es necesario
  ),
];

// Nueva opción de "Salir"
MenuOption exitOption = MenuOption(
  icon: Icons.logout,
  title: "Salir",
  view: LoginForm(), // Reemplaza con la vista correspondiente si es necesario
);
