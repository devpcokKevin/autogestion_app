import 'package:flutter/material.dart';

import '../models/sidebar_options.dart';

class SideMenuTile extends StatelessWidget {
  const SideMenuTile({
    Key? key,
    required this.menu,
    required this.press,
    required this.isActive,
  }) : super(key: key);

  final MenuOption menu;
  final VoidCallback press;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24),
          child: Divider(
            color: Colors.white24,
            height: 1,
          ),
        ),
        Stack(
          children: [
            ListTile(
              onTap: press,
              leading: Icon(
                menu.icon,
                size: 34,
                color: isActive ? Colors.blue : Colors.white,
              ),
              title: Text(
                menu.title,
                style: TextStyle(
                  color: isActive ? Colors.blue : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
