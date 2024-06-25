import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _token;
  Map<String, dynamic>? _decodedToken;
  List<dynamic>? _authorities;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  // Guardar token en SharedPreferences
  Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _loadToken();
  }

  // Cargar token desde SharedPreferences y decodificarlo
  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    setState(() {
      _token = token;
      if (token != null) {
        _decodedToken = JwtDecoder.decode(token);
        _authorities = _decodedToken?['authorities'];  // O 'roles' dependiendo de tu implementación
      }
    });
  }

  // Eliminar token desde SharedPreferences
  Future<void> _removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    setState(() {
      _token = null;
      _decodedToken = null;
      _authorities = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JWT Decoder Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Token: $_token'),
            Text('Decoded Token: $_decodedToken'),
            Text('Authorities: $_authorities'),
            ElevatedButton(
              onPressed: () async {
                // Simula guardar un token
                String exampleToken = 'your_jwt_token_here';
                await _saveToken(exampleToken);
              },
              child: Text('Save Token'),
            ),
            ElevatedButton(
              onPressed: _removeToken,
              child: Text('Remove Token'),
            ),
          ],
        ),
      ),
    );
  }
}
