import 'package:autogestion/components/side_menu_tile.dart';
import 'package:autogestion/models/rive_asset.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'info_card.dart';

// Welcome to the Episode 5
class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 288,
        height: double.infinity,
        color: Color(0xFF023E73),
        child: SafeArea(
          child: Column(
            children: [
              const InfoCard(
                nombre: "Jorge Mantilla",
                cargo: "Developer",
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "RR.HH".toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white70),
                ),
              ),
              // here is the icon rive asset because it's animated asset
              ...sideMenus.map(
                (menu) => SideMenuTile(
                  menu: menu,
                  riveonInit: (artboard) {},
                  press: () {},
                  isActive: false,
                ),
              )
            ],
          ),
        ),
      ), // Container
    ); // SafeArea
  }
}
