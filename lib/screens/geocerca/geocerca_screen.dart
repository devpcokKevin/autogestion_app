import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/adapter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import 'components/address_info.dart';
import '../../shared/appbar.dart';
import 'components/geocerca_info.dart';
import '../../Enviroment/Variables.dart';

class GoogleMapScreen extends StatefulWidget {
  final String appBarTitle;
  final IconData appBarIcon;

  const GoogleMapScreen({
    Key? key,
    required this.appBarTitle,
    required this.appBarIcon,
  }) : super(key: key);

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor markerbitmap = BitmapDescriptor.defaultMarker;

  LatLng initialLocation = const LatLng(-8.100742, -79.033865);
  LatLng? blueMarkerLocation;

  List<LatLng> polygonPoints = [];
  LatLng? movingPoint;

  bool isRadioButtonChecked = true;
  bool resetCircleRadius = false; // Bandera para restablecer el radio
  bool showAreaButtons = false; // Mostrar/ocultar los botones

  TextEditingController areaNameController = TextEditingController();
  TextEditingController areaDescriptionController = TextEditingController();

  double circleRadius = 60.0; // Radio inicial del círculo
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool hasSelectedGeocerca = false;

  @override
  void initState() {
    super.initState();
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

    _determinePosition().then((position) {
      setState(() {
        initialLocation = LatLng(position.latitude, position.longitude);
      });
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  String selectedGeocercaNombre = '';
  String selectedGeocercaDescripcion = '';

  // Actualiza la posición de un punto que se está moviendo.
  void _updateMovingPointPosition(LatLng newPosition) {
    setState(() {
      if (movingPoint != null) {
        final index = polygonPoints.indexOf(movingPoint!);
        if (index != -1) {
          polygonPoints[index] = newPosition;
          movingPoint = newPosition;
        }
      }
    });
  }

  // Finaliza el movimiento de un punto.
  void _finalizeMovingPoint() {
    setState(() {
      movingPoint = null;
    });
  }

  // Agrega un nuevo punto al polígono.
  void _addPolygonPoint(LatLng point) {
    setState(() {
      polygonPoints.add(point);
    });
  }

  // Elimina un punto del polígono.
  void _removePolygonPoint(LatLng point) {
    setState(() {
      polygonPoints.remove(point);
      movingPoint = null;
    });
  }

  void _showDeleteOption(LatLng point, {bool isBlueMarker = false}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Eliminar ${isBlueMarker ? 'marcador' : 'punto'}'),
                onTap: () {
                  Navigator.pop(context);
                  if (isBlueMarker) {
                    setState(() {
                      blueMarkerLocation = null;
                      resetCircleRadius = true; // Activar la bandera para restablecer el radio
                    });
                  } else {
                    _removePolygonPoint(point);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _savePolygonPoints() async {
    // Obtener el nombre y la descripción del área de los controladores de texto
    String geocerca_nombre = areaNameController.text;
    String geocerca_descripcion = areaDescriptionController.text;

    // Construir la lista de puntos del polígono para data_delimitador
    List<Map<String, dynamic>> data_delimitador = polygonPoints.map((point) {
      return {
        'delimitador_latitud': point.latitude.toString(),
        'delimitador_longitud': point.longitude.toString()
      };
    }).toList();

    // Aquí puedes llamar a _sendAreaDataToServer si necesitas enviar los datos al servidor
    _sendAreaDataToServer(
        geocerca_nombre, geocerca_descripcion, data_delimitador);

    // Cerrar el modal
    Navigator.of(context).pop();
  }

  // Modal Guardar Geocerca
  void modalGuardarGeocerca() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Guardar geocerca"),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300),
              // Ajusta el valor según sea necesario
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: areaNameController,
                    decoration: InputDecoration(hintText: "Nombre"),
                  ),
                  SizedBox(height: 16), // Espacio entre los campos de texto
                  TextField(
                    controller: areaDescriptionController,
                    decoration: InputDecoration(hintText: "Descripción"),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Guardar"),
              onPressed: () {
                _savePolygonPoints();
              },
            ),
          ],
        );
      },
    );
  }

  // Método para enviar los datos del área al servidor
  void _sendAreaDataToServer(String geocerca_nombre, String geocerca_descripcion,
      List<Map<String, dynamic>> data_delimitador) async {
    var dio = Dio();
    var url = '$baseUrl/api/Geocerca/regGeocercaDelimitador';
    var datageo = {
      "empresa_codigo": "20354561124",
      "geocerca_nombre": geocerca_nombre,
      "geocerca_descripcion": geocerca_descripcion,
      "data_delimitador": data_delimitador
    };

    print(datageo);

    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: datageo,
      );

      if (response.statusCode == 200) {
        print('---------------------------------------------------');
        print('Respuesta del servidor: ${response.data}');
        print('---------------------------------------------------');
      } else {
        print('Error: ${response.statusCode}');
        print('Error: ${response}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchGeocercas() async {
    var dio = Dio();
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
    var url = '$baseUrl/api/Geocerca/ListaGeocerca?empresa_codigo=20354561124';
    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('item3')) {
          return List<Map<String, dynamic>>.from(data['item3']);
        } else {
          print('Formato de respuesta inesperado: ${response.data}');
          return [];
        }
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<void> postSelectedGeocerca(String geocercaId) async {
    var dio = Dio();
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
    var url = '$baseUrl/api/Geocerca/listGeocercaDelimitador';
    var data = {
      "empresa_codigo": "20354561124",
      "geocerca_id": geocercaId,
    };
    try {
      final response = await dio.post(url, data: data);
      if (response.statusCode == 200) {
        isRadioButtonChecked = false;
        polygonPoints.clear();
        var responseData = response.data;
        if (responseData.containsKey('item3') &&
            responseData['item3'].containsKey('data_delimitador')) {
          List delimiters = responseData['item3']['data_delimitador'];
          for (var delimiter in delimiters) {
            double lat = double.parse(delimiter['delimitador_latitud']);
            double lng = double.parse(delimiter['delimitador_longitud']);
            _addPolygonPoint(LatLng(lat, lng));
          }
        }
        setState(() {
          hasSelectedGeocerca = true;
        });
        _slideController.forward();
      } else {
        print('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void showGeocercasModal(BuildContext context) async {
    List<Map<String, dynamic>> geocercas = await fetchGeocercas();
    print(geocercas);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Seleccione una geocerca',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(
                thickness: 1,
                height: 20,
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: geocercas.length,
                  itemBuilder: (BuildContext context, int index) {
                    String nombre = geocercas[index]['geocercaSelect_nombre'] ?? 'Nombre no disponible';
                    String descripcion = geocercas[index]['geocercaSelect_descripcion'] ?? 'Descripción no disponible';

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 16.0),
                      title: Text(nombre),
                      onTap: () {
                        setState(() {
                          selectedGeocercaNombre = nombre;
                          selectedGeocercaDescripcion = descripcion;
                          print("geocerca nombre: $selectedGeocercaNombre");
                          print("geocerca descripcion: $selectedGeocercaDescripcion");
                        });
                        Navigator.pop(context, geocercas[index]['geocercaSelect_id']);
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      thickness: 1,
                      height: 1,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).then((selectedGeocercaId) async {
      if (selectedGeocercaId != null) {
        print('Geocerca seleccionada con ID: $selectedGeocercaId');
        await postSelectedGeocerca(selectedGeocercaId);
      }
    });
  }

  void toggleAreaButtons() {
    setState(() {
      showAreaButtons = !showAreaButtons;
    });
  }

  void selectArea(bool isRadioButton) {
    setState(() {
      isRadioButtonChecked = isRadioButton;
      blueMarkerLocation = null;
      polygonPoints.clear();
      showAreaButtons = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: "Geocerca",
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
                    target: initialLocation,
                    zoom: 18,
                  ),
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId("initialMarker"),
                      draggable: true,
                      position: initialLocation,
                      onDragEnd: (newPosition) {
                        setState(() {
                          initialLocation = newPosition;
                        });
                      },
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed),
                    ),
                    if (isRadioButtonChecked && blueMarkerLocation != null)
                      Marker(
                        markerId: const MarkerId("blueMarker"),
                        draggable: true,
                        position: blueMarkerLocation!,
                        onDrag: (newPosition) {
                          setState(() {
                            blueMarkerLocation = newPosition;
                          });
                        },
                        onTap: () => _showDeleteOption(blueMarkerLocation!,
                            isBlueMarker: true),
                        onDragEnd: (newPosition) {
                          setState(() {
                            blueMarkerLocation = newPosition;
                          });
                        },
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue),
                      ),
                    if (!isRadioButtonChecked)
                      ...polygonPoints.asMap().entries.map((entry) {
                        final index = entry.key;
                        final point = entry.value;
                        return Marker(
                          markerId: MarkerId(point.toString()),
                          position: point,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue,
                          ),
                          draggable: true,
                          onTap: () => _showDeleteOption(point),
                          onDragStart: (newPosition) {
                            setState(() {
                              movingPoint = point;
                            });
                          },
                          onDragEnd: (newPosition) {
                            _updateMovingPointPosition(newPosition);
                            _finalizeMovingPoint();
                          },
                        );
                      }),
                  },
                  polygons: !isRadioButtonChecked && polygonPoints.length >= 3
                      ? {
                    Polygon(
                      polygonId: PolygonId("1"),
                      points: polygonPoints,
                      fillColor: Colors.blue.withOpacity(0.5),
                      strokeColor: Colors.blue,
                      strokeWidth: 2,
                    ),
                  }
                      : {},
                  circles: isRadioButtonChecked && blueMarkerLocation != null
                      ? {
                    Circle(
                      circleId: CircleId("blueCircle"),
                      center: blueMarkerLocation!,
                      radius: circleRadius,
                      fillColor: Colors.blue.withOpacity(0.5),
                      strokeColor: Colors.blue,
                      strokeWidth: 2,
                    ),
                  }
                      : {},
                  onTap: (point) {
                    setState(() {
                      if (isRadioButtonChecked) {
                        blueMarkerLocation = point;
                        if (resetCircleRadius) {
                          circleRadius =
                          60.0; // Restablecer el radio a 60 metros solo después de eliminar
                          resetCircleRadius = false; // Restablecer la bandera
                        }
                        _slideController.reverse();
                        hasSelectedGeocerca = false;
                      } else {
                        _addPolygonPoint(point);
                        _slideController.reverse();
                        hasSelectedGeocerca = false;
                      }
                    });
                  },
                ),
              ),
              Visibility(
                visible: hasSelectedGeocerca,
                child: GeocercaInfo(
                  geocerca_nombre: selectedGeocercaNombre,
                  geocerca_descripcion: selectedGeocercaDescripcion,
                ),
              ),
            ],
          ),
          if (isRadioButtonChecked && blueMarkerLocation != null)
            Positioned(
              top: 20,
              left: 20,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.purple.shade900,
                        width: 3.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        circleRadius.toInt().toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.18,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Slider(
                        value: circleRadius,
                        min: 10,
                        max: 110,
                        activeColor: Colors.purple,
                        inactiveColor: Colors.purple[100],
                        onChanged: (value) {
                          setState(() {
                            circleRadius = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showAreaButtons)
                      Row(
                        children: [
                          SlideTransition(
                            position: _slideAnimation,
                            child: FloatingActionButton(
                              onPressed: () {
                                selectArea(true);
                              },
                              child: Icon(Icons.radio_button_checked),
                              backgroundColor: Colors.blue,
                              shape: CircleBorder(),
                            ),
                          ),
                          SizedBox(width: 16),
                          SlideTransition(
                            position: _slideAnimation,
                            child: FloatingActionButton(
                              onPressed: () {
                                selectArea(false);
                              },
                              child: Icon(Icons.add_location_alt),
                              backgroundColor: Colors.blue,
                              shape: CircleBorder(),
                            ),
                          ),
                          SizedBox(width: 16),
                        ],
                      ),
                    FloatingActionButton(
                      onPressed: () {
                        toggleAreaButtons();
                        if (showAreaButtons) {
                          _slideController.forward();
                        } else {
                          _slideController.reverse();
                        }
                      },
                      child: Icon(Icons.tune),
                      backgroundColor: Colors.blue,
                      shape: CircleBorder(),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () {
                    modalGuardarGeocerca();
                  },
                  child: Icon(Icons.save),
                  backgroundColor: Colors.green,
                  shape: CircleBorder(),
                ),
                SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () {
                    showGeocercasModal(context);
                  },
                  child: Icon(Icons.view_list),
                  backgroundColor: Colors.deepPurpleAccent,
                  shape: CircleBorder(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
