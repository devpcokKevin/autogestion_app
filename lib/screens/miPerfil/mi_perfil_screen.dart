import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autogestion/shared/appbar.dart';

class miPerfilScreen extends StatefulWidget {
  final String appBarTitle;
  final IconData appBarIcon;

  const miPerfilScreen({Key? key, required this.appBarTitle, required this.appBarIcon}) : super(key: key);

  @override
  State<miPerfilScreen> createState() => _miPerfilScreenState();
}

class _miPerfilScreenState extends State<miPerfilScreen> {
  final GlobalKey globalKey = GlobalKey();

  String usuarioNombre = ""; // Variable para almacenar el nombre del usuario
  String usuarioCargo = "";
  String usuarioId = "";
  String razonSocial = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? razonSocialPref = prefs.getString('razon_social');
    if (razonSocialPref != null) {
      setState(() {
        razonSocial = razonSocialPref;
      });
    }
    String? datosUsuarioJson = prefs.getString('datosUsuario');
    if (datosUsuarioJson != null) {
      Map<String, dynamic> datosUsuario = jsonDecode(datosUsuarioJson);
      setState(() {
        usuarioNombre = datosUsuario['usuario_nombre'];
        usuarioCargo = datosUsuario['usuario_cargo'];
        usuarioId = datosUsuario['usuario_id'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: widget.appBarTitle,
        icon: widget.appBarIcon,
        implyLeading: false,
        marginLeft: 50.0, // Ajusta el margen según sea necesario
      ),
    );
  }
}
