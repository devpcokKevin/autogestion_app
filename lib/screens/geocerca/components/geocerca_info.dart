import 'package:flutter/material.dart';

class GeocercaInfo extends StatelessWidget {
  // Propiedades para almacenar el nombre y la descripción de la geocerca
  final String geocerca_nombre;
  final String geocerca_descripcion;

  // Constructor que recibe las propiedades y las inicializa
  const GeocercaInfo({
    Key? key,
    required this.geocerca_nombre,
    required this.geocerca_descripcion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Construye el widget de la información de la geocerca
    return Container(
      width: double.infinity, // Ocupa todo el ancho disponible
      padding: EdgeInsets.all(16.0), // Añade un padding alrededor del contenido
      color: Colors.white, // Color de fondo del contenedor
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ajusta el tamaño de la columna al contenido
        children: [
          // Título de la sección
          Text(
            'Información de la Geocerca',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold, // Texto en negrita
            ),
          ),
          SizedBox(height: 3), // Espacio entre el título y el nombre
          // Muestra el nombre de la geocerca
          Text(
            'Nombre: $geocerca_nombre',
            style: TextStyle(
              fontSize: 12.0,
            ),
            textAlign: TextAlign.center, // Centra el texto horizontalmente
          ),
          SizedBox(height: 8.0), // Espacio entre el nombre y la descripción
          // Muestra la descripción de la geocerca
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
