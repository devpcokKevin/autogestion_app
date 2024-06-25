import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? icon;
  final bool implyLeading;
  final double marginLeft;

  CustomAppBar({
    required this.title,
    this.icon,
    this.implyLeading = true,
    this.marginLeft = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: implyLeading,
      backgroundColor: Color(0xFF023E73),
      title: Row(
        children: [
          Container(
            margin: EdgeInsets.only(left: marginLeft), // Ajusta el margen según sea necesario
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
          SizedBox(width: 8),
          if (icon != null)
            Icon(
              icon,
              size: 28,
              color: Colors.white,
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
