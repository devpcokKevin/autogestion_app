// Importa los paquetes necesarios si es necesario
import 'package:flutter/material.dart';

// Define la clase Login con los atributos dados
class Login {
  String empresa_codigo;
  String empresa_password;
  String usuario_codigo;
  String usuario_password;

  // Constructor de la clase para inicializar los atributos
  Login({
    required this.empresa_codigo,
    required this.empresa_password,
    required this.usuario_codigo,
    required this.usuario_password,
  });

  Map<String, String> toJson() {
    return {
      'empresa_codigo': empresa_codigo,
      'empresa_password': empresa_password,
      'usuario_codigo': usuario_codigo,
      'usuario_password': usuario_password,
    };
  }

  // Método toString para representar la clase como una cadena
  @override
  String toString() {
    return 'Login(empresa_codigo: $empresa_codigo, empresa_password: $empresa_password, usuario_codigo: $usuario_codigo, usuario_password: $usuario_password)';
  }
}
