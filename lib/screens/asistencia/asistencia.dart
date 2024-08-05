import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

import 'package:dio/adapter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/appbar.dart';
import '../geocerca/components/address_info.dart';
import '../../Enviroment/Variables.dart';

class AsistenciaScreen extends StatefulWidget {
  final String appBarTitle;
  final IconData appBarIcon;

  const AsistenciaScreen({
    Key? key,
    required this.appBarTitle,
    required this.appBarIcon,
  }) : super(key: key);

  @override
  State<AsistenciaScreen> createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  Location location = Location();
  BitmapDescriptor markerbitmap = BitmapDescriptor.defaultMarker;

  LatLng initialLocation = const LatLng(-8.100742, -79.033865);
  LatLng? currentLocation;
  LatLng? geocercaCenter;
  double geocercaRadius = 0.0;
  List<LatLng> geocercaPolygon = [];

  bool locationFetched = false;
  bool isIntheDeliveryArea = false;
  bool mapLoaded = false; // Nueva variable para rastrear si el mapa está cargado
  bool showAreaButtons = false;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Inicializa el controlador de animación para transiciones
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.fastOutSlowIn,
    ));
    _initializeLocation(); // Inicializa la ubicación al iniciar
  }

  Future<void> _initializeLocation() async {
    // Verifica y solicita permisos de ubicación, obtiene la ubicación actual del dispositivo
    if (!locationFetched) {
      try {
        bool serviceEnabled = await location.serviceEnabled();
        if (!serviceEnabled) {
          serviceEnabled = await location.requestService();
          if (!serviceEnabled) {
            return;
          }
        }

        PermissionStatus permissionGranted = await location.hasPermission();
        if (permissionGranted == PermissionStatus.denied) {
          permissionGranted = await location.requestPermission();
          if (permissionGranted != PermissionStatus.granted) {
            return;
          }
        }

        final locationData = await location.getLocation();
        setState(() {
          currentLocation = LatLng(locationData.latitude ?? initialLocation.latitude, locationData.longitude ?? initialLocation.longitude);
          locationFetched = true; // Marca como obtenida la ubicación
        });

        // Después de obtener la ubicación, comprobar si está dentro de la geocerca
        _checkIfInGeocerca();
      } catch (e) {
        print('Error al obtener la ubicación: $e');
      }
    }
  }

  void _checkIfInGeocerca() {
    // Verifica si la ubicación actual está dentro de una geocerca
    if (currentLocation != null) {
      if (geocercaCenter != null && geocercaRadius > 0) {
        // Verificación para geocerca circular
        double distance = _calculateDistance(currentLocation!, geocercaCenter!);
        setState(() {
          isIntheDeliveryArea = distance <= geocercaRadius;
        });
      } else if (geocercaPolygon.isNotEmpty) {
        // Verificación para geocerca poligonal
        setState(() {
          isIntheDeliveryArea = _isPointInPolygon(currentLocation!, geocercaPolygon);
        });
      }
    }
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    // Calcula la distancia entre dos puntos usando la fórmula de la esfera (distancia geodésica)
    const double radiusOfEarth = 6371000; // Radio de la Tierra en metros
    double lat1 = point1.latitude;
    double lon1 = point1.longitude;
    double lat2 = point2.latitude;
    double lon2 = point2.longitude;

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radiusOfEarth * c;
  }

  double _toRadians(double degree) {
    // Convierte grados a radianes
    return degree * pi / 180;
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    // Verifica si un punto está dentro de un polígono
    bool isInside = false;
    int nPoints = polygon.length;
    int j = nPoints - 1;

    for (int i = 0; i < nPoints; j = i++) {
      double xi = polygon[i].latitude, yi = polygon[i].longitude;
      double xj = polygon[j].latitude, yj = polygon[j].longitude;

      bool intersect = ((yi > point.longitude) != (yj > point.longitude)) &&
          (point.latitude < (xj - xi) * (point.longitude - yi) / (yj - yi) + xi);
      if (intersect) {
        isInside = !isInside;
      }
    }

    return isInside;
  }

  Future<void> _fetchGeocercaAsignada() async {
    // Obtiene la geocerca asignada al trabajador desde el servidor
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var empresaCodigo = prefs.getString('empresa_codigo') ?? '';
    var datosUsuario2 = prefs.getString('datosUsuario');

    if (datosUsuario2 != null) {
      var decodedDatosUsuario = json.decode(datosUsuario2);
      var trabajadorId = decodedDatosUsuario['trabajador_id'] ?? '';

      print('empresa_codigo: $empresaCodigo');
      print('trabajador_id: $trabajadorId');

      if (empresaCodigo.isNotEmpty && trabajadorId.isNotEmpty) {
        var dio = Dio();
        (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
          client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
          return client;
        };

        var url = '$baseUrl/api/Geocerca/listGeocercaDelimitadorTrabajador';

        var data = {
          "empresa_codigo": empresaCodigo,
          "trabajador_id": trabajadorId,
        };

        try {
          final response = await dio.post(url, data: data);
          if (response.statusCode == 200) {
            var responseData = response.data;
            print('Respuesta de la API: ${responseData}');

            if (responseData['item3'] != null && responseData['item3']['data_delimitador'] != null) {
              var geocerca = responseData['item3'];
              setState(() {
                // Resetear la geocerca
                geocercaCenter = null;
                geocercaRadius = 0.0;
                geocercaPolygon = [];

                // Verificar si es una geocerca circular o poligonal
                if (geocerca['data_delimitador'] is List && geocerca['data_delimitador'].isNotEmpty) {
                  var delimitador = geocerca['data_delimitador'][0];
                  if (delimitador['delimitador_radio'] != null && delimitador['delimitador_radio'].isNotEmpty) {
                    // Geocerca circular
                    double lat = double.parse(delimitador['delimitador_latitud']);
                    double lng = double.parse(delimitador['delimitador_longitud']);
                    geocercaCenter = LatLng(lat, lng);
                    geocercaRadius = double.parse(delimitador['delimitador_radio']);
                  } else {
                    // Geocerca poligonal
                    geocercaPolygon = geocerca['data_delimitador'].map<LatLng>((point) {
                      return LatLng(
                        double.parse(point['delimitador_latitud']),
                        double.parse(point['delimitador_longitud']),
                      );
                    }).toList();
                  }

                  // Comprobar si la ubicación actual está dentro de la geocerca
                  _checkIfInGeocerca();

                  // Mover la cámara a la geocerca
                  _moveCameraToGeocerca();
                } else {
                  isIntheDeliveryArea = false;
                  Fluttertoast.showToast(msg: 'No se encontraron datos de delimitador.');
                }
              });
            } else {
              isIntheDeliveryArea = false;
              print('No se encontraron geocercas asignadas.');
              Fluttertoast.showToast(msg: 'No se encontraron geocercas asignadas.');
            }
          } else {
            isIntheDeliveryArea = false;
            print('Error en la solicitud: ${response.statusCode}');
            Fluttertoast.showToast(msg: 'Error al obtener geocerca asignada.');
          }
        } catch (e) {
          isIntheDeliveryArea = false;
          print('Error en la solicitud: $e');
          Fluttertoast.showToast(msg: 'Error al obtener geocerca asignada.');
        }
      } else {
        Fluttertoast.showToast(msg: 'Error: empresaCodigo o trabajadorId están vacíos');
      }
    } else {
      Fluttertoast.showToast(msg: 'No se encontraron datos de usuario.');
    }
  }

  Future<void> _fetchAsistencia_reg(asistenciaTrabajador_tipo) async {
    String currentDateTime = DateTime.now().toLocal().toString().substring(0, 19);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var empresaCodigo = prefs.getString('empresa_codigo') ?? '20354561124'; // Default if not found
    var datosUsuario2 = prefs.getString('datosUsuario');

    if (datosUsuario2 != null) {
      var decodedDatosUsuario = json.decode(datosUsuario2);
      var trabajadorId = decodedDatosUsuario['trabajador_id'] ?? '';

      var dio = Dio();
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };

      var url = '$baseUrl/api/AsistenciaTrabajador/regAsistenciaTrabajador';

      var data = {
        "trabajador_id": trabajadorId,
        "asistenciaTrabajador_fecha": currentDateTime,
        "asistenciaTrabajador_tipo": asistenciaTrabajador_tipo,
        "marcador_id": "2",
        "asistenciaTrabajador_serviceWppStatus": "P"
      };

      try {
        final response = await dio.post(
          url,
          data: data,
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "empresa_codigo": empresaCodigo,
            },
          ),
        );
        if (response.statusCode == 200) {
          var responseData = response.data;
          Fluttertoast.showToast(
            msg: responseData['item2'], // Acceder a 'item2' usando corchetes
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        print('Error en la solicitud: $e');
        Fluttertoast.showToast(msg: 'Error al registrar asistencia.');
      }
    } else {
      Fluttertoast.showToast(msg: 'No se encontraron datos de usuario.');
    }
  }


  void _moveCameraToGeocerca() async {
    // Mueve la cámara del mapa a la ubicación de la geocerca
    final GoogleMapController controller = await _controller.future;
    if (geocercaCenter != null) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(geocercaCenter!, 15));
    } else if (geocercaPolygon.isNotEmpty) {
      LatLngBounds bounds = _getLatLngBounds(geocercaPolygon);
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  LatLngBounds _getLatLngBounds(List<LatLng> points) {
    // Obtiene los límites del LatLng para ajustar la vista del mapa
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Construye la interfaz de usuario principal
    if (!locationFetched) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _buildAsistencia(context);
  }

  Widget _buildAsitenciaButtons() {
    // Muestra los botones para seleccionar el tipo de área (círculo o polígono)
    return Stack(
      children: [
        AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          top: 60.0,
          right: showAreaButtons ? 80.0 : 20.0,
          child: SizedBox(
            width: 45,
            height: 60,
            child: FloatingActionButton(
              onPressed: () {
                _fetchAsistencia_reg("0");
              },
              child: Icon(Icons.logout),
              backgroundColor: Colors.red,
              shape: CircleBorder(),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          top: 60.0,
          right: showAreaButtons ? 140.0 : 20.0,
          child: SizedBox(
            width: 45,
            height: 60,
            child: FloatingActionButton(
              onPressed: () {
                _fetchAsistencia_reg("1");
              },
              child: Icon(Icons.login),
              backgroundColor: Colors.green,
              shape: CircleBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAsistencia(BuildContext context) {
    // Construye la interfaz de asistencia con el mapa y los botones de acción
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: widget.appBarTitle,
        icon: widget.appBarIcon,
        implyLeading: false,
        marginLeft: 50.0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: currentLocation ?? initialLocation,
                    zoom: 18,
                  ),
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                    setState(() {
                      mapLoaded = true; // El mapa está cargado
                    });
                    _fetchGeocercaAsignada();
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _buildMarkers(), // Construye los marcadores en el mapa
                  circles: _buildCircles(), // Construye los círculos en el mapa
                  polygons: _buildPolygons(), // Construye los polígonos en el mapa
                ),
              ),
              // Añadir el AddressInfo aquí
              AddressInfo(isIntheDeliveryArea: isIntheDeliveryArea),
            ],
          ),
          _buildActionButtons(),
          if (showAreaButtons) _buildAsitenciaButtons(),// Muestra los botones de asistencia solo si showAreaButtons es true
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    // Construye los marcadores para el mapa
    final markers = <Marker>{};

    if (geocercaCenter != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("geocercaCenter"),
          position: geocercaCenter!,
          icon: BitmapDescriptor.fromBytes(Uint8List.fromList([0])), // Ícono transparente
        ),
      );
    }

    return markers;
  }

  Set<Circle> _buildCircles() {
    // Construye los círculos en el mapa para representar las geocercas circulares
    final circles = <Circle>{};

    if (geocercaCenter != null) {
      circles.add(
        Circle(
          circleId: CircleId("geocercaCircle"),
          center: geocercaCenter!,
          radius: geocercaRadius,
          fillColor: Colors.blue.withOpacity(0.5),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      );
    }

    return circles;
  }

  Set<Polygon> _buildPolygons() {
    // Construye los polígonos en el mapa para representar las geocercas poligonales
    final polygons = <Polygon>{};

    if (geocercaPolygon.isNotEmpty) {
      polygons.add(
        Polygon(
          polygonId: PolygonId("geocercaPolygon"),
          points: geocercaPolygon,
          fillColor: Colors.blue.withOpacity(0.5),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      );
    }

    return polygons;
  }
  void toggleAreaButtons() {
    // Alterna la visibilidad de los botones de selección de área
    setState(() {
      showAreaButtons = !showAreaButtons;
    });
  }

  Widget _buildActionButtons() {
    // Construye los botones de acción, incluyendo la opción para obtener la geocerca asignada
    return Positioned(
      top: 60,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 45,
            height: 60,
            child: FloatingActionButton(
              onPressed: () {
                toggleAreaButtons(); // Alterna la visibilidad de los botones de área
              }, // Llamada a la función para obtener la geocerca asignada
              child: Icon(Icons.how_to_reg),
              backgroundColor: Colors.orange,
              shape: CircleBorder(),
            ),
          ),
        ],
      ),
    );

  }
}
