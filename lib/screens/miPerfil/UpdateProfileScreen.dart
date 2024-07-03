import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class UpdateProfileScreen extends StatefulWidget {
  final String usuarioNombre;

  const UpdateProfileScreen({Key? key, required this.usuarioNombre}) : super(key: key);

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  String? imagePath; // Variable para la ruta de la imagen de perfil

  Future<void> _selectImageFromCamera() async {
    var pickedFile = await ImagePicker().getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        // Guarda la ruta de la imagen tomada desde la cámara
        imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF023E73),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(LineAwesomeIcons.angle_left),
          color: Colors.white,
        ),
        title: Text(
          "Editar Perfil",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(35.0),
          child: Column(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: _selectImageFromCamera,
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipOval(
                        child: Container(
                          color: Colors.grey[200], // Color de fondo para el círculo
                          child: imagePath != null
                              ? Image.file(File(imagePath!)) // Muestra la imagen tomada desde la cámara
                              : Image.asset('images/profile.png'), // Imagen por defecto
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 0,
                    child: GestureDetector(
                      onTap: _selectImageFromCamera,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Color(0xFF023E73),
                        ),
                        child: const Icon(
                          LineAwesomeIcons.camera,
                          color: Colors.white,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: widget.usuarioNombre,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(color: Colors.black),
                        prefixIcon: Icon(LineAwesomeIcons.user),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: const BorderSide(width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: const BorderSide(width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'E-MAIL',
                        labelStyle: TextStyle(color: Colors.black),
                        prefixIcon: Icon(LineAwesomeIcons.envelope_1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: const BorderSide(width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: const BorderSide(width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Telefono',
                        labelStyle: TextStyle(color: Colors.black),
                        prefixIcon: Icon(LineAwesomeIcons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: const BorderSide(width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: const BorderSide(width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: TextStyle(color: Colors.black),
                        prefixIcon: Icon(LineAwesomeIcons.fingerprint),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: const BorderSide(width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: const BorderSide(width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Lógica para guardar los cambios del perfil
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF023E73),
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          "Guardar Cambios",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: const [
                        Text.rich(
                          TextSpan(
                            text: "Tus datos están seguros. ",
                            style: TextStyle(fontSize: 12),
                            children: [
                              TextSpan(
                                text: "Autogestion",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
