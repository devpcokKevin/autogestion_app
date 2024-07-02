import 'package:flutter/material.dart';

class AddressInfo extends StatelessWidget {
  final bool isIntheDeliveryArea;

  const AddressInfo({
    Key? key,
    required this.isIntheDeliveryArea,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información de la Dirección',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 3),
          Text(
            isIntheDeliveryArea
                ? 'Está dentro del área de entrega.'
                : 'Fuera del área de entrega.',
            style: TextStyle(
              fontSize: 14,
              color: isIntheDeliveryArea ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
