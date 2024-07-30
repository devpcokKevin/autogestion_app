import 'dart:async';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Location location = Location();
  BitmapDescriptor markerbitmap = BitmapDescriptor.defaultMarker;

  LatLng initialLocation = const LatLng(-8.100742, -79.033865);
  LatLng? currentLocation;
  LatLng? blueMarkerLocation;

  List<LatLng> polygonPoints = [];
  LatLng? movingPoint;

  bool isRadioButtonChecked = true;
  bool resetCircleRadius = false;
  bool showAreaButtons = false;
  bool isSaveButtonEnabled = false;
  bool isGeocercaSelected = false;
  bool isEditMode = false;
  bool locationFetched = false;

  TextEditingController areaNameController = TextEditingController();
  TextEditingController areaDescriptionController = TextEditingController();

  double circleRadius = 60.0;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool hasSelectedGeocerca = false;
  List<Map<String, dynamic>> geocercas = [];

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
    _initializeLocation(); // Inicializar la ubicación al iniciar
  }

  Future<void> _initializeLocation() async {
    if (!locationFetched) { // Verificar si ya se ha obtenido la ubicación
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
          locationFetched = true; // Marcar como obtenida la ubicación
        });
      } catch (e) {
        print('Error al obtener la ubicación: $e');
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    areaNameController.dispose();
    areaDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!locationFetched) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _buildGoogleMap(context);
  }

  Widget _buildGoogleMap(BuildContext context) {
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
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _buildMarkers(),
                  polygons: _buildPolygons(),
                  circles: _buildCircles(),
                  onTap: _handleMapTap,
                ),
              ),
              if (hasSelectedGeocerca)
                GeocercaInfo(
                  geocerca_nombre: selectedGeocercaNombre,
                  geocerca_descripcion: selectedGeocercaDescripcion,
                ),
            ],
          ),
          _buildRadiusSlider(),
          _buildAreaButtons(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (isRadioButtonChecked && blueMarkerLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("blueMarker"),
          draggable: isGeocercaSelected ? isEditMode : true,
          position: blueMarkerLocation!,
          onDrag: _handleMarkerDrag,
          onTap: _handleMarkerTap,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    if (!isRadioButtonChecked) {
      markers.addAll(
        polygonPoints.map(
              (point) => Marker(
            markerId: MarkerId(point.toString()),
            position: point,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            draggable: isGeocercaSelected ? isEditMode : true,
            onTap: () => _showDeleteOption(point),
            onDragStart: (newPosition) {
              if (isGeocercaSelected ? isEditMode : true) {
                setState(() {
                  movingPoint = point;
                });
              }
            },
            onDragEnd: (newPosition) {
              if (isGeocercaSelected ? isEditMode : true) {
                _updateMovingPointPosition(newPosition);
                _finalizeMovingPoint();
              }
            },
          ),
        ),
      );
    }

    return markers;
  }

  Set<Polygon> _buildPolygons() {
    if (!isRadioButtonChecked && polygonPoints.length >= 3) {
      return {
        Polygon(
          polygonId: PolygonId("1"),
          points: polygonPoints,
          fillColor: Colors.blue.withOpacity(0.5),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      };
    }
    return {};
  }

  Set<Circle> _buildCircles() {
    if (isRadioButtonChecked && blueMarkerLocation != null) {
      return {
        Circle(
          circleId: CircleId("blueCircle"),
          center: blueMarkerLocation!,
          radius: circleRadius,
          fillColor: Colors.blue.withOpacity(0.5),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      };
    }
    return {};
  }

  void _handleMapTap(LatLng point) {
    if (!isGeocercaSelected || (isGeocercaSelected && isEditMode)) {
      setState(() {
        if (isRadioButtonChecked) {
          blueMarkerLocation = point;
          if (resetCircleRadius) {
            circleRadius = 60.0;
            resetCircleRadius = false;
          }
          _slideController.reverse();
          hasSelectedGeocerca = false;
        } else {
          _addPolygonPoint(point);
          _slideController.reverse();
          hasSelectedGeocerca = false;
        }
        showAreaButtons = false;
        _updateSaveButtonState();
      });
    }
  }

  void _handleMarkerDrag(LatLng newPosition) {
    if (isGeocercaSelected ? isEditMode : true) {
      setState(() {
        blueMarkerLocation = newPosition;
      });
      _updateSaveButtonState();
    }
  }

  void _handleMarkerTap() {
    if (isGeocercaSelected ? isEditMode : true) {
      _showDeleteOption(blueMarkerLocation!, isBlueMarker: true);
      setState(() {
        showAreaButtons = false;
      });
    }
  }

  Widget _buildRadiusSlider() {
    if (!isRadioButtonChecked || blueMarkerLocation == null) return Container();

    return Positioned(
      top: 60,
      left: 20,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.purple,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.purpleAccent,
                width: 3.0,
              ),
            ),
            child: Center(
              child: Text(
                circleRadius.toInt().toString(),
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
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
                onChanged: isEditMode || !isGeocercaSelected
                    ? (value) {
                  setState(() {
                    circleRadius = value;
                    hasSelectedGeocerca = false;
                    _updateSaveButtonState();
                  });
                }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaButtons() {
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
                selectArea(true);
              },
              child: Icon(Icons.radio_button_checked),
              backgroundColor: isRadioButtonChecked ? Colors.lightBlueAccent : Colors.blue,
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
                selectArea(false);
              },
              child: Icon(Icons.add_location_alt),
              backgroundColor: !isRadioButtonChecked ? Colors.lightBlueAccent : Colors.blue,
              shape: CircleBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
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
                toggleAreaButtons();
              },
              child: Icon(Icons.crop_rotate),
              backgroundColor: Colors.blue,
              shape: CircleBorder(),
            ),
          ),
          SizedBox(
            width: 45,
            height: 60,
            child: FloatingActionButton(
              onPressed: isSaveButtonEnabled
                  ? () {
                if (isGeocercaSelected && !isEditMode) {
                  _toggleEditMode();
                } else if (isEditMode) {
                  modalEditarGeocerca();
                } else {
                  modalGuardarGeocerca();
                }
              }
                  : null,
              child: Icon(isGeocercaSelected && !isEditMode ? Icons.edit : Icons.save),
              backgroundColor: isSaveButtonEnabled ? Colors.lightGreenAccent : Colors.grey,
              shape: CircleBorder(),
            ),
          ),
          SizedBox(
            width: 45,
            height: 60,
            child: FloatingActionButton(
              onPressed: () {
                showGeocercasModal(context);
                setState(() {
                  showAreaButtons = false;
                });
              },
              child: Icon(Icons.view_list),
              backgroundColor: Colors.purpleAccent,
              shape: CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  void _updateSaveButtonState() {
    setState(() {
      isSaveButtonEnabled = blueMarkerLocation != null || polygonPoints.length >= 3;
    });
  }

  String selectedGeocercaNombre = '';
  String selectedGeocercaDescripcion = '';
  String? selectedGeocercaId;

  void _updateMovingPointPosition(LatLng newPosition) {
    setState(() {
      if (movingPoint != null) {
        final index = polygonPoints.indexOf(movingPoint!);
        if (index != -1) {
          polygonPoints[index] = newPosition;
          movingPoint = newPosition;
        }
        hasSelectedGeocerca = false;
        _updateSaveButtonState();
      }
    });
  }

  void _finalizeMovingPoint() {
    setState(() {
      movingPoint = null;
      hasSelectedGeocerca = false;
    });
    _updateGeocercaInfoVisibility();
    _updateSaveButtonState();
  }

  void _addPolygonPoint(LatLng point) {
    setState(() {
      polygonPoints.add(point);
    });
    _updateGeocercaInfoVisibility();
    _updateSaveButtonState();
  }

  void _removePolygonPoint(LatLng point) {
    setState(() {
      polygonPoints.remove(point);
      movingPoint = null;
      hasSelectedGeocerca = false;
    });
    _updateGeocercaInfoVisibility();
    _updateSaveButtonState();
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
                      resetCircleRadius = true;
                      showAreaButtons = false;
                      hasSelectedGeocerca = false;
                      _updateSaveButtonState();
                    });
                  } else {
                    _removePolygonPoint(point);
                    showAreaButtons = false;
                    hasSelectedGeocerca = false;
                    _updateSaveButtonState();
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_sweep),
                title: Text('Eliminar todos los puntos'),
                onTap: () {
                  Navigator.pop(context);
                  _removeAllPoints();
                  showAreaButtons = false;
                  hasSelectedGeocerca = false;
                  _updateSaveButtonState();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeAllPoints() {
    setState(() {
      blueMarkerLocation = null;
      polygonPoints.clear();
      resetCircleRadius = true;
      showAreaButtons = false;
      hasSelectedGeocerca = false;
    });
    _updateSaveButtonState();
  }

  void _savePolygonPoints() async {
    String geocerca_nombre = selectedGeocercaNombre;
    String geocerca_descripcion = selectedGeocercaDescripcion;

    List<Map<String, dynamic>> data_delimitador = polygonPoints.map((point) {
      return {'delimitador_latitud': point.latitude.toString(), 'delimitador_longitud': point.longitude.toString(), 'delimitador_radio': null};
    }).toList();

    _sendAreaDataToServer(geocerca_nombre, geocerca_descripcion, data_delimitador, selectedGeocercaId);

    setState(() {
      showAreaButtons = false;
      isEditMode = false;
    });
  }

  void _saveCircleArea() async {
    String geocerca_nombre = selectedGeocercaNombre;
    String geocerca_descripcion = selectedGeocercaDescripcion;

    List<Map<String, dynamic>> data_delimitador = [
      {'delimitador_latitud': blueMarkerLocation!.latitude.toString(), 'delimitador_longitud': blueMarkerLocation!.longitude.toString(), 'delimitador_radio': circleRadius.toString()}
    ];

    _sendAreaDataToServer(geocerca_nombre, geocerca_descripcion, data_delimitador, selectedGeocercaId);

    setState(() {
      showAreaButtons = false;
      isEditMode = false;
    });
  }

  void modalGuardarGeocerca() async {
    setState(() {
      showAreaButtons = false;
      areaNameController.clear();
      areaDescriptionController.clear();
    });

    if (isSaveButtonEnabled) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Guardar geocerca"),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: areaNameController,
                      decoration: InputDecoration(hintText: "Nombre"),
                    ),
                    SizedBox(height: 16),
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
                onPressed: isSaveButtonEnabled
                    ? () {
                  setState(() {
                    selectedGeocercaNombre = areaNameController.text;
                    selectedGeocercaDescripcion = areaDescriptionController.text;
                    selectedGeocercaId = null;
                  });
                  if (isRadioButtonChecked && blueMarkerLocation != null) {
                    _saveCircleArea();
                  } else {
                    _savePolygonPoints();
                  }
                  Navigator.of(context).pop();
                }
                    : null,
                style: TextButton.styleFrom(
                  foregroundColor: isSaveButtonEnabled ? Colors.lightGreen : Colors.grey,
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void modalEditarGeocerca() async {
    setState(() {
      showAreaButtons = false;
      areaNameController.text = selectedGeocercaNombre;
      areaDescriptionController.text = selectedGeocercaDescripcion;
    });

    if (isSaveButtonEnabled) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Editar geocerca"),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: areaNameController,
                      decoration: InputDecoration(hintText: "Nombre"),
                    ),
                    SizedBox(height: 16),
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
                onPressed: isSaveButtonEnabled
                    ? () {
                  setState(() {
                    selectedGeocercaNombre = areaNameController.text;
                    selectedGeocercaDescripcion = areaDescriptionController.text;
                  });
                  if (isRadioButtonChecked && blueMarkerLocation != null) {
                    _saveCircleArea();
                  } else {
                    _savePolygonPoints();
                  }
                  Navigator.of(context).pop();
                }
                    : null,
                style: TextButton.styleFrom(
                  foregroundColor: isSaveButtonEnabled ? Colors.lightGreen : Colors.grey,
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _sendAreaDataToServer(String geocerca_nombre, String geocerca_descripcion, List<Map<String, dynamic>> data_delimitador, String? geocercaId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dio = Dio();
    var url = geocercaId != null
        ? '$baseUrl/api/Geocerca/updGeocercaDelimitador'
        : '$baseUrl/api/Geocerca/regGeocercaDelimitador';

    var empresa_codigo = prefs.get("empresa_codigo");
    var data = {"empresa_codigo": empresa_codigo, "data_delimitador": data_delimitador};

    if (geocercaId != null) {
      data["geocerca_id"] = geocercaId;
      data["geocerca_nombre"] = geocerca_nombre;
      data["geocerca_descripcion"] = geocerca_descripcion;
    } else {
      data["geocerca_nombre"] = geocerca_nombre;
      data["geocerca_descripcion"] = geocerca_descripcion;
    }

    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        print('Respuesta del servidor: ${response.data}');
        Fluttertoast.showToast(msg: 'Geocerca guardada');
        await fetchGeocercas();
      } else {
        print('Error: ${response.statusCode}');
        print('Error: ${response}');
        Fluttertoast.showToast(msg: 'Error al guardar la geocerca');
      }
    } catch (e) {
      print('Error: $e');
      Fluttertoast.showToast(msg: 'Error al guardar la geocerca');
    }
  }

  Future<void> fetchGeocercas() async {
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
          setState(() {
            geocercas = List<Map<String, dynamic>>.from(data['item3']);
          });
        } else {
          print('Formato de respuesta inesperado: ${response.data}');
          setState(() {
            geocercas = [];
          });
        }
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        setState(() {
          geocercas = [];
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        geocercas = [];
      });
    }
  }

  Future<void> postSelectedGeocerca(String geocercaId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var dio = Dio();
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    var url = '$baseUrl/api/Geocerca/listGeocercaDelimitador';
    var empresa_codigo = prefs.get("empresa_codigo");

    var data = {
      "empresa_codigo": empresa_codigo,
      "geocerca_id": geocercaId,
    };
    try {
      final response = await dio.post(url, data: data);
      if (response.statusCode == 200) {
        isRadioButtonChecked = false;
        polygonPoints.clear();
        LatLngBounds bounds;

        var responseData = response.data;
        if (responseData.containsKey('item3') && responseData['item3'].containsKey('data_delimitador')) {
          List delimiters = responseData['item3']['data_delimitador'];
          print(delimiters);

          selectedGeocercaNombre = responseData['item3']['geocerca_nombre'] ?? '';
          selectedGeocercaDescripcion = responseData['item3']['geocerca_descripcion'] ?? '';

          bounds = _getLatLngBounds(delimiters);

          for (var delimiter in delimiters) {
            try {
              double lat = double.parse(delimiter['delimitador_latitud']);
              double lng = double.parse(delimiter['delimitador_longitud']);

              if (delimiter['delimitador_radio'] != null && delimiter['delimitador_radio'] != '') {
                double radius = double.parse(delimiter['delimitador_radio']);
                setState(() {
                  blueMarkerLocation = LatLng(lat, lng);
                  circleRadius = radius;
                  isRadioButtonChecked = true;
                  hasSelectedGeocerca = true;
                  isGeocercaSelected = true;
                  isEditMode = false;
                  selectedGeocercaId = geocercaId;
                });
              } else {
                setState(() {
                  _addPolygonPoint(LatLng(lat, lng));
                  isRadioButtonChecked = false;
                  hasSelectedGeocerca = true;
                  isGeocercaSelected = true;
                  isEditMode = false;
                  selectedGeocercaId = geocercaId;
                });
              }
            } catch (e) {
              print('Error al convertir coordenadas: $e');
            }
          }
          _moveCameraToBounds(bounds);
        }
        _slideController.forward();
        _updateSaveButtonState();
      } else {
        print('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  LatLngBounds _getLatLngBounds(List delimiters) {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (var delimiter in delimiters) {
      double lat = double.parse(delimiter['delimitador_latitud']);
      double lng = double.parse(delimiter['delimitador_longitud']);

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _moveCameraToBounds(LatLngBounds bounds) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  double parseCoordinate(String coord) {
    try {
      return double.parse(coord.replaceAll(',', '.'));
    } catch (e) {
      print('Error al convertir coordenada: $e');
      throw FormatException('Invalid coordinate format');
    }
  }

  void showGeocercasModal(BuildContext context) async {
    setState(() {
      showAreaButtons = false;
    });

    await fetchGeocercas();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(nombre),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => _confirmDeleteGeocerca(context, geocercas[index]['geocercaSelect_id'], setState),
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              selectedGeocercaNombre = nombre;
                              selectedGeocercaDescripcion = descripcion;
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
        );
      },
    ).then((selectedGeocercaId) async {
      if (selectedGeocercaId != null) {
        await postSelectedGeocerca(selectedGeocercaId);
      }
    });
  }

  void _confirmDeleteGeocerca(BuildContext context, String geocercaId, StateSetter setState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Eliminar geocerca"),
          content: Text("¿Estás seguro de que deseas eliminar esta geocerca?"),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Eliminar"),
              onPressed: () {
                _deleteGeocerca(geocercaId, setState);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteGeocerca(String geocercaId, StateSetter setState) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dio = Dio();
    var url = '$baseUrl/api/Geocerca/delGeocercaDelimitador';
    var empresa_codigo = prefs.get("empresa_codigo");

    var data = {
      "empresa_codigo": empresa_codigo,
      "geocerca_id": geocercaId,
    };

    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        print('Geocerca eliminada: ${response.data}');
        Fluttertoast.showToast(msg: 'Geocerca eliminada');
        setState(() {
          geocercas.removeWhere((geocerca) => geocerca['geocercaSelect_id'] == geocercaId);
        });
      } else {
        print('Error al eliminar geocerca: ${response.statusCode}');
        Fluttertoast.showToast(msg: 'Error al eliminar geocerca');
      }
    } catch (e) {
      print('Error: $e');
      Fluttertoast.showToast(msg: 'Error al eliminar geocerca');
    }
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
      isGeocercaSelected = false;
      isEditMode = false;
      _updateGeocercaInfoVisibility();
      _updateSaveButtonState();
    });
  }

  void _updateGeocercaInfoVisibility() {
    setState(() {
      hasSelectedGeocerca = blueMarkerLocation != null || polygonPoints.isNotEmpty;
    });
  }

  void _toggleEditMode() {
    setState(() {
      isEditMode = !isEditMode;
      if (!isEditMode) {
        modalEditarGeocerca();
      }
    });
  }
}
