import 'package:flutter/material.dart';

class GeocercaInfo extends StatelessWidget {
  final String geocerca_nombre;
  final String geocerca_descripcion;

  const GeocercaInfo({
    Key? key,
    required this.geocerca_nombre,
    required this.geocerca_descripcion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Información de la Geocerca',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 3),
          Text(
            'Nombre: $geocerca_nombre',
            style: TextStyle(
              fontSize: 12.0,
            ),
            textAlign: TextAlign.center, // Centra el texto horizontalmente
          ),
          SizedBox(height: 8.0),
          Text(
            'Descripción: $geocerca_descripcion',
            style: TextStyle(
              fontSize: 12.0,
            ),
            textAlign: TextAlign.center, // Centra el texto horizontalmente
          ),
        ],
      ),
    );
  }
}
