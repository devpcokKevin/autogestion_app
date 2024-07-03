import 'dart:convert';
import 'dart:io'; // Necesario para File
import 'package:autogestion/screens/miPerfil/UpdateProfileScreen.dart';
import 'package:autogestion/screens/miPerfil/widgets/ProfileMenuWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
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
  String? imagePath; // Variable para la ruta de la imagen de perfil

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

  Future<void> _selectImageFromGallery() async {
    var pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        // Guarda la ruta de la imagen seleccionada
        imagePath = pickedFile.path;
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
        marginLeft: 50.0,
        // Ajusta el margen según sea necesario
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(35.0),
          child: Column(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: _selectImageFromGallery,
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: imagePath != null
                            ? Image.file(File(imagePath!)) // Muestra la imagen seleccionada
                            : Image.asset('images/profile.png'), // Imagen por defecto
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 0,
                    child: GestureDetector(
                      onTap: _selectImageFromGallery,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Color(0xFF023E73),
                        ),
                        child: const Icon(
                          LineAwesomeIcons.alternate_pencil,
                          size: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(usuarioNombre, style: Theme.of(context).textTheme.headlineSmall),
              Text(usuarioCargo, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => UpdateProfileScreen(usuarioNombre: usuarioNombre)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF023E73),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              // Menu
              ProfileMenuWidget(title: "Settings", icon: LineAwesomeIcons.cog, onPress: () {}),
              ProfileMenuWidget(title: "Money", icon: LineAwesomeIcons.wallet, onPress: () {}),
              ProfileMenuWidget(title: "User Management", icon: LineAwesomeIcons.user_check, onPress: () {}),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              ProfileMenuWidget(title: "Information", icon: LineAwesomeIcons.info, onPress: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
