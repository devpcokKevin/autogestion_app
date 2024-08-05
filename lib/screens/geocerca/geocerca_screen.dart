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

class GeocercaScreen extends StatefulWidget {
  final String appBarTitle;
  final IconData appBarIcon;

  const GeocercaScreen({
    Key? key,
    required this.appBarTitle,
    required this.appBarIcon,
  }) : super(key: key);

  @override
  State<GeocercaScreen> createState() => _GeocercaScreenState();
}

class _GeocercaScreenState extends State<GeocercaScreen> with SingleTickerProviderStateMixin {
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
    // Inicializa el controlador de animación y la animación de desplazamiento
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
    // Verifica y solicita permisos de ubicación, y obtiene la ubicación actual del dispositivo
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
          locationFetched = true; // Marcar como obtenida la ubicación
        });
      } catch (e) {
        print('Error al obtener la ubicación: $e');
      }
    }
  }

  @override
  void dispose() {
    // Libera recursos cuando la pantalla se destruye
    _slideController.dispose();
    areaNameController.dispose();
    areaDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Muestra un indicador de progreso mientras se obtiene la ubicación
    if (!locationFetched) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _buildGeocerca(context);
  }

  Widget _buildGeocerca(BuildContext context) {
    // Construye la interfaz principal que incluye el mapa y las opciones de geocerca
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
                  markers: _buildMarkers(), // Construye los marcadores en el mapa
                  polygons: _buildPolygons(), // Construye los polígonos en el mapa
                  circles: _buildCircles(), // Construye los círculos en el mapa
                  onTap: _handleMapTap, // Maneja los toques en el mapa
                ),
              ),
              if (hasSelectedGeocerca)
                GeocercaInfo(
                  geocerca_nombre: selectedGeocercaNombre,
                  geocerca_descripcion: selectedGeocercaDescripcion,
                ),
            ],
          ),
          _buildRadiusSlider(), // Construye el control deslizante para el radio del círculo
          _buildAreaButtons(), // Construye los botones para seleccionar área de geocerca
          _buildActionButtons(), // Construye los botones de acción
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    // Construye los marcadores para el mapa
    final markers = <Marker>{};

    if (isRadioButtonChecked && blueMarkerLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("blueMarker"),
          draggable: isGeocercaSelected ? isEditMode : true,
          position: blueMarkerLocation!,
          onDrag: _handleMarkerDrag, // Maneja el arrastre del marcador
          onTap: _handleMarkerTap, // Maneja el toque en el marcador
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
            onTap: () => _showDeleteOption(point), // Muestra opciones de eliminación para el punto
            onDragStart: (newPosition) {
              if (isGeocercaSelected ? isEditMode : true) {
                setState(() {
                  movingPoint = point;
                });
              }
            },
            onDragEnd: (newPosition) {
              if (isGeocercaSelected ? isEditMode : true) {
                _updateMovingPointPosition(newPosition); // Actualiza la posición del punto en movimiento
                _finalizeMovingPoint(); // Finaliza el movimiento del punto
              }
            },
          ),
        ),
      );
    }

    return markers;
  }

  Set<Polygon> _buildPolygons() {
    // Construye los polígonos en el mapa
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
    // Construye los círculos en el mapa
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
    // Maneja los toques en el mapa para agregar un marcador o punto de polígono
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
    // Maneja el arrastre de un marcador para cambiar su posición
    if (isGeocercaSelected ? isEditMode : true) {
      setState(() {
        blueMarkerLocation = newPosition;
      });
      _updateSaveButtonState();
    }
  }

  void _handleMarkerTap() {
    // Muestra opciones para eliminar un marcador al tocarlo
    if (isGeocercaSelected ? isEditMode : true) {
      _showDeleteOption(blueMarkerLocation!, isBlueMarker: true);
      setState(() {
        showAreaButtons = false;
      });
    }
  }

  Widget _buildRadiusSlider() {
    // Muestra un control deslizante para ajustar el radio de un círculo alrededor de un marcador
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
    // Muestra los botones de acción (guardar, editar, ver lista)
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
                  _toggleEditMode(); // Activa el modo de edición
                } else if (isEditMode) {
                  modalEditarGeocerca(); // Abre el modal para editar la geocerca
                } else {
                  modalGuardarGeocerca(); // Abre el modal para guardar la geocerca
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
                showGeocercasModal(context); // Muestra el modal de lista de geocercas
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
    // Actualiza el estado del botón de guardar según la selección actual
    setState(() {
      isSaveButtonEnabled = blueMarkerLocation != null || polygonPoints.length >= 3;
    });
  }

  String selectedGeocercaNombre = '';
  String selectedGeocercaDescripcion = '';
  String? selectedGeocercaId;

  void _updateMovingPointPosition(LatLng newPosition) {
    // Actualiza la posición del punto en movimiento
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
    // Finaliza el movimiento del punto y actualiza la visibilidad de la información de la geocerca
    setState(() {
      movingPoint = null;
      hasSelectedGeocerca = false;
    });
    _updateGeocercaInfoVisibility();
    _updateSaveButtonState();
  }

  void _addPolygonPoint(LatLng point) {
    // Añade un nuevo punto al polígono
    setState(() {
      polygonPoints.add(point);
    });
    _updateGeocercaInfoVisibility();
    _updateSaveButtonState();
  }

  void _removePolygonPoint(LatLng point) {
    // Elimina un punto del polígono
    setState(() {
      polygonPoints.remove(point);
      movingPoint = null;
      hasSelectedGeocerca = false;
    });
    _updateGeocercaInfoVisibility();
    _updateSaveButtonState();
  }

  void _showDeleteOption(LatLng point, {bool isBlueMarker = false}) {
    // Muestra las opciones para eliminar un punto o marcador
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
                  _removeAllPoints(); // Elimina todos los puntos del polígono
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
    // Elimina todos los puntos y resetea el estado
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
    // Guarda los puntos del polígono en el servidor
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
    // Guarda el área circular en el servidor
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
    // Muestra el modal para guardar una nueva geocerca
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
                    _saveCircleArea(); // Guarda un área circular
                  } else {
                    _savePolygonPoints(); // Guarda un área de polígono
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
    // Muestra el modal para editar una geocerca existente
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
                    _saveCircleArea(); // Guarda el área circular editada
                  } else {
                    _savePolygonPoints(); // Guarda los puntos del polígono editados
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
    // Envía los datos del área al servidor para guardarlos o actualizarlos
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
        await fetchGeocercas(); // Obtiene la lista actualizada de geocercas
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
    // Obtiene la lista de geocercas del servidor
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
    // Envía la geocerca seleccionada al servidor y la muestra en el mapa
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
          _moveCameraToBounds(bounds); // Mueve la cámara a los límites de la geocerca
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
    // Obtiene los límites del LatLng para ajustar la vista del mapa
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
    // Mueve la cámara del mapa a los límites de la geocerca
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  double parseCoordinate(String coord) {
    // Convierte una coordenada en formato de texto a double
    try {
      return double.parse(coord.replaceAll(',', '.'));
    } catch (e) {
      print('Error al convertir coordenada: $e');
      throw FormatException('Invalid coordinate format');
    }
  }

  void showGeocercasModal(BuildContext context) async {
    // Muestra el modal con la lista de geocercas
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
                                onPressed: () => _confirmDeleteGeocerca(context, geocercas[index]['geocercaSelect_id'], setState), // Confirma la eliminación de la geocerca
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
    // Muestra un cuadro de diálogo de confirmación para eliminar una geocerca
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
                _deleteGeocerca(geocercaId, setState); // Elimina la geocerca
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteGeocerca(String geocercaId, StateSetter setState) async {
    // Elimina una geocerca del servidor
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dio = Dio();
    var url = '$baseUrl/api/Geocerca/delGeocercaDelimitador';
    var empresaCodigo = prefs.get("empresa_codigo");

    var data = {
      "empresa_codigo": empresaCodigo,
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
    // Alterna la visibilidad de los botones de selección de área
    setState(() {
      showAreaButtons = !showAreaButtons;
    });
  }

  void selectArea(bool isRadioButton) {
    // Selecciona el tipo de área (círculo o polígono)
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
    // Actualiza la visibilidad de la información de la geocerca
    setState(() {
      hasSelectedGeocerca = blueMarkerLocation != null || polygonPoints.isNotEmpty;
    });
  }

  void _toggleEditMode() {
    // Alterna el modo de edición
    setState(() {
      isEditMode = !isEditMode;
      if (!isEditMode) {
        modalEditarGeocerca();
      }
    });
  }
}
