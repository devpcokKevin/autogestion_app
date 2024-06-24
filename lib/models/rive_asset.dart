import 'package:autogestion/src/app.dart';
import 'package:rive/rive.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/widgets.dart';
import '../generador_qr.dart';

class RiveAsset {
  final String artboard, stateMachineName, title, src;
  final Widget? view;
  late SMIBool? input;

  RiveAsset(this.src,
      {required this.artboard,
      required this.stateMachineName,
      required this.title,
      this.view,
      this.input});

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
    view: QrScreen(),
  ),
  RiveAsset(
    "assets/RiveAssets/icons.riv",
    artboard: "SEARCH",
    stateMachineName: "SEARCH_Interactivity",
    title: "Buscar",
  ),
  RiveAsset(
    "assets/RiveAssets/icons.riv",
    artboard: "LIKE/STAR",
    stateMachineName: "STAR_Interactivity",
    title: "Favoritos",
  ),
  RiveAsset(
    "assets/RiveAssets/icons.riv",
    artboard: "CHAT",
    stateMachineName: "CHAT_Interactivity",
    title: "Ayuda",
  ),
];

List<RiveAsset> sideMenu2 = [
  RiveAsset(
    "assets/RiveAssets/icons.riv",
    artboard: "TIMER",
    stateMachineName: "TIMER_Interactivity",
    title: "History",
  ),
  RiveAsset(
    "assets/RiveAssets/icons.riv",
    artboard: "BELL",
    stateMachineName: "BELL_Interactivity",
    title: "Notificaciones",
  ),
];
