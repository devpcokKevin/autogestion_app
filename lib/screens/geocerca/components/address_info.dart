import 'package:flutter/material.dart';

class AddressInfo extends StatelessWidget {
  // Propiedad para indicar si la ubicación está dentro del área de entrega
  final bool isIntheDeliveryArea;

  // Constructor que inicializa la propiedad isIntheDeliveryArea
  const AddressInfo({
    Key? key,
    required this.isIntheDeliveryArea,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Construye la interfaz del widget
    return Padding(
      padding: const EdgeInsets.all(10.0), // Añade un padding alrededor del widget
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido al inicio (izquierda)
        children: [
          // Título de la sección
          Text(
            'Información de la Geocerca',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold, // Texto en negrita
            ),
          ),
          SizedBox(height: 3), // Espacio entre el título y el estado de la entrega
          // Muestra si está dentro o fuera del área de entrega
          Text(
            isIntheDeliveryArea
                ? 'Está dentro del área de trabajo.' // Mensaje si está dentro del área de entrega
                : 'Fuera del área de trabajo.', // Mensaje si está fuera del área de entrega
            style: TextStyle(
              fontSize: 14,
              color: isIntheDeliveryArea ? Colors.green : Colors.red, // Cambia el color del texto según el estado
            ),
          ),
        ],
      ),
    );
  }
}
