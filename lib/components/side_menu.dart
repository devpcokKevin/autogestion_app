import 'dart:convert';

import 'package:autogestion/components/side_menu_tile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sidebar_options.dart';
import 'info_card.dart';

class SideMenu extends StatefulWidget {
  final VoidCallback onExitOptionClicked; // Añadir un callback para la opción de salir
  final Function(Widget) onMenuItemClicked;

  const SideMenu({required this.onMenuItemClicked, required this.onExitOptionClicked, super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  MenuOption selectedMenu = sideMenus.first;
  String usuarioNombre = "";
  String usuarioCargo = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? datosUsuarioJson = prefs.getString('datosUsuario');
    if (datosUsuarioJson != null) {
      Map<String, dynamic> datosUsuario = jsonDecode(datosUsuarioJson);
      setState(() {
        usuarioNombre = datosUsuario['usuario_nombre'];
        usuarioCargo = datosUsuario['usuario_cargo'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 288,
        height: double.infinity,
        color: const Color(0xFF023E73),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoCard(
                nombre: usuarioNombre,
                cargo: usuarioCargo,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "General".toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white70),
                ),
              ),
              ...sideMenus.map(
                (menu) => SideMenuTile(
                  menu: menu,
                  press: () {
                    if (menu.onTap != null) {
                      menu.onTap!();
                    }
                    widget.onMenuItemClicked(menu.view!); // Notifica al EntryPoint de la vista seleccionada
                    setState(() {
                      selectedMenu = menu;
                    });
                  },
                  isActive: selectedMenu == menu,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "RR.HH".toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white70),
                ),
              ),
              ...sideMenu2.map(
                (menu) => SideMenuTile(
                  menu: menu,
                  press: () {
                    widget.onMenuItemClicked(menu.view!); // Notifica al EntryPoint de la vista seleccionada
                    setState(() {
                      selectedMenu = menu;
                    });
                  },
                  isActive: selectedMenu == menu,
                ),
              ),
              const Spacer(),
              SideMenuTile(
                menu: exitOption,
                press: () {
                  if (exitOption.onTap != null) {
                    exitOption.onTap!();
                  }

                  widget.onMenuItemClicked(exitOption.view!); // Notifica al EntryPoint de la vista seleccionada
                  widget.onExitOptionClicked();

                  setState(() {
                    selectedMenu = exitOption;
                  });
                },
                isActive: selectedMenu == exitOption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
