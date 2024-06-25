class Usuario {
  String captcha;
  DatosUsuario datosUsuario;

  Usuario({
    required this.captcha,
    required this.datosUsuario,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      captcha: json['captcha'],
      datosUsuario: DatosUsuario.fromJson(json['datosUsuario']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['captcha'] = this.captcha;
    data['datosUsuario'] = this.datosUsuario.toJson();
    return data;
  }
}

class DatosUsuario {
  String usuarioCodigo;
  String usuarioNombre;
  String usuarioCargo;
  String usuarioNivel;
  dynamic usuarioPrograma;
  dynamic usuarioAcceso;

    DatosUsuario({
    required this.usuarioCodigo,
    required this.usuarioNombre,
    required this.usuarioCargo,
    required this.usuarioNivel,
    this.usuarioPrograma,
    this.usuarioAcceso,
  });

  factory DatosUsuario.fromJson(Map<String, dynamic> json) {
    return DatosUsuario(
      usuarioCodigo: json['usuario_codigo'],
      usuarioNombre: json['usuario_nombre'],
      usuarioCargo: json['usuario_cargo'],
      usuarioNivel: json['usuario_nivel'],
      usuarioPrograma: json['usuario_programa'],
      usuarioAcceso: json['usuario_acceso'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['usuario_codigo'] = this.usuarioCodigo;
    data['usuario_nombre'] = this.usuarioNombre;
    data['usuario_cargo'] = this.usuarioCargo;
    data['usuario_nivel'] = this.usuarioNivel;
    data['usuario_programa'] = this.usuarioPrograma;
    data['usuario_acceso'] = this.usuarioAcceso;
    return data;
  }
}
