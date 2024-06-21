// Importa los paquetes necesarios si es necesario
import 'package:flutter/material.dart';

// Define la clase Login con los atributos dados
class Login {
  String empresaCodigo;
  String empresaPassword;
  String usuarioCodigo;
  String usuarioPassword;
  String tipoCambio;
  String fechaProceso;

  // Constructor de la clase para inicializar los atributos
  Login({
    required this.empresaCodigo,
    required this.empresaPassword,
    required this.usuarioCodigo,
    required this.usuarioPassword,
    required this.tipoCambio,
    required this.fechaProceso,
  });

  Map<String, dynamic> toJson() {
    return {
      'empresa_codigo': empresaCodigo,
      'empresa_password': empresaPassword,
      'usuario_codigo': usuarioCodigo,
      'usuario_password': usuarioPassword,
      'tipo_cambio': tipoCambio,
      'fecha_proceso': fechaProceso,
    };
  }

}
