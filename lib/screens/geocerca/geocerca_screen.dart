import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../shared/appbar.dart';
import 'components/address_info.dart';

class GoogleMapScreen extends StatefulWidget {
  final String appBarTitle;
  final IconData appBarIcon;

  const GoogleMapScreen({Key? key, required this.appBarTitle, required this.appBarIcon}) : super(key: key);

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor markerbitmap = BitmapDescriptor.defaultMarker;

  LatLng initialLocation = const LatLng(-8.100742, -79.033865);

  List<LatLng> polygonPoints = const [
    LatLng(-8.10081708996039, -79.03387105965153),
    LatLng(-8.100645813725436, -79.03378388785895),
    LatLng(-8.100746720663377, -79.03358138107922),
    LatLng(-8.100911358244659, -79.03365380072229),
  ];

  bool isInDeliveryArea = true;
  bool isRadioButtonChecked = true;
  double deliveryRadius = 30;

  void _updateMarkerPosition(LatLng position) {
    if (isRadioButtonChecked) {
      final distance = _calculateDistance(initialLocation, position);
      setState(() {
        isInDeliveryArea = distance <= deliveryRadius;
      });
    } else {
      setState(() {
        isInDeliveryArea = _isPointInPolygon(position, polygonPoints);
      });
    }
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // meters
    final double dLat = _degreesToRadians(point2.latitude - point1.latitude);
    final double dLon = _degreesToRadians(point2.longitude - point1.longitude);
    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_degreesToRadians(point1.latitude)) * cos(_degreesToRadians(point2.latitude)) * sin(dLon / 2) * sin(dLon / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int n = polygon.length;
    int i, j = n - 1;
    bool result = false;
    for (i = 0; i < n; i++) {
      if ((polygon[i].latitude > point.latitude) != (polygon[j].latitude > point.latitude) &&
          (point.longitude < (polygon[j].longitude - polygon[i].longitude) * (point.latitude - polygon[i].latitude) /
              (polygon[j].latitude - polygon[i].latitude) +
              polygon[i].longitude)) {
        result = !result;
      }
      j = i;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.appBarTitle,
        icon: widget.appBarIcon,
        implyLeading: false,
        marginLeft: 50.0, // Ajusta el margen según sea necesario
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialLocation,
                    zoom: 20,
                  ),
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId("1"),
                      draggable: true,
                      position: initialLocation,
                      icon: markerbitmap,
                      onDragEnd: (newPosition) {
                        _updateMarkerPosition(newPosition);
                      },
                    ),
                  },
                  circles: isRadioButtonChecked
                      ? {
                    Circle(
                      circleId: CircleId("1"),
                      center: initialLocation,
                      radius: deliveryRadius,
                      strokeWidth: 2,
                      fillColor: Color(0xFF006491).withOpacity(0.2),
                    ),
                  }
                      : {},
                  polygons: !isRadioButtonChecked
                      ? {
                    Polygon(
                      polygonId: PolygonId("1"),
                      points: polygonPoints,
                      strokeWidth: 2,
                      fillColor: Color(0xFF006491).withOpacity(0.2),
                    ),
                  }
                      : {},
                ),
              ),
              AddressInfo(
                isIntheDeliveryArea: isInDeliveryArea,
              ),
            ],
          ),
          Positioned(
            top: 10,
            right: 10,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  isRadioButtonChecked = !isRadioButtonChecked;
                  _updateMarkerPosition(initialLocation); // Actualizar la posición del marcador al cambiar entre áreas
                });
              },
              child: Icon(isRadioButtonChecked ? Icons.radio_button_checked : Icons.add_location_alt),
              backgroundColor: Colors.blue,
              shape: CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
