import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    Key? key,
    required this.nombre,
    required this.cargo,
  }) : super(key: key);

  final String nombre, cargo;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.white24,
        child: Icon(
          CupertinoIcons.person,
          color: Colors.white,
        ),
      ),
      title: Text(
        nombre,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        cargo,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}