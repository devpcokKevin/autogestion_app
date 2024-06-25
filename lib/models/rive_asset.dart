import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../generador_qr.dart';
import '../screens/qr/qrScanner.dart';
import '../src/login.dart';

class RiveAsset {
  final String artboard, stateMachineName, title, src;
  final Widget? view;
  late SMIBool? input;

  RiveAsset(
      this.src, {
        required this.artboard,
        required this.stateMachineName,
        required this.title,
        this.view,
        this.input,
      });

  set setInput(SMIBool status) {
    input = status;
  }
}

List<RiveAsset> sideMenus = [
  RiveAsset(
    "assets/RiveAssets/icons.riv",
    artboard: "HOME",
    stateMachineName: "HOME_interactivity",
    title: "Inicio",
    view: LoginForm(),
  ),
  RiveAsset(
    "assets/RiveAssets/little_icons.riv",
    artboard: "DASHBOARD",
    stateMachineName: "State Machine 1",
    title: "Mi QR",
    view: QrScreen(appBarTitle: "MI QR", appBarIcon: Icons.qr_code_scanner),
  ),
  RiveAsset(
    "assets/RiveAssets/icons.riv",
    artboard: "SEARCH",
    stateMachineName: "SEARCH_Interactivity",
    title: "Buscar",
    view: null, // Reemplaza con la vista correspondiente si es necesario
  ),
  RiveAsset(
    "assets/RiveAssets/icons.riv",
    artboard: "LIKE/STAR",
    stateMachineName: "STAR_Interactivity",
    title: "Favoritos",
    view: QRScanner(appBarTitle: "Scanner", appBarIcon: Icons.barcode_reader), // Reemplaza con la vista correspondiente si es necesario
  ),
  RiveAsset(
    "assets/RiveAssets/icons.riv",
    artboard: "CHAT",
    stateMachineName: "CHAT_Interactivity",
    title: "Ayuda",
    view: null, // Reemplaza con la vista correspondiente si es necesario
  ),
];

List<RiveAsset> sideMenu2 = [
  RiveAsset(
    "assets/RiveAssets/icons.riv",
    artboard: "TIMER",
    stateMachineName: "TIMER_Interactivity",
    title: "History",
    view: null, // Reemplaza con la vista correspondiente si es necesario
  ),
  RiveAsset(
    "assets/RiveAssets/icons.riv",
    artboard: "BELL",
    stateMachineName: "BELL_Interactivity",
    title: "Notificaciones",
    view: null, // Reemplaza con la vista correspondiente si es necesario
  ),
];