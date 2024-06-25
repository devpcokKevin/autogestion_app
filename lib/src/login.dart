import 'package:autogestion/entry_point.dart';
import 'package:flutter/material.dart';
import 'package:autogestion/screens/home/home_screen.dart';

class LoginForm extends StatefulWidget {
  LoginForm({Key? key}) : super(key: key);

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  String _codigoEmpresa = "";
  String _contrasenaEmpresa = "";
  String _codigoUsuario = "";
  String _contrasenaUsuario = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 90.0),
        children: <Widget>[

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              SizedBox(height: 30.0),

              Container(
                width: 100.0, // Ancho deseado para la imagen
                height: 100.0, // Alto deseado para la imagen
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    fit: BoxFit.cover, // Ajusta la imagen dentro del contenedor
                    image: AssetImage('images/logo.png'),
                  ),
                ),
              ),

              SizedBox(height: 20.0),

              Text(
                'Autogestión',
                style: TextStyle(
                  fontFamily: 'Montserrat-SemiBold',
                  fontSize: 40.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF023E73),
                ),
              ),

              Text(
                'Inicio de Sesión',
                style:
                    TextStyle(
                        fontFamily: 'Montserrat-Medium', fontSize: 20.0,
                        color: Color(0xFF023E73),
                    ),
              ),

              SizedBox(height: 20.0),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Código Empresa',
                  labelText: 'Código Empresa',
                  suffixIcon: Icon(Icons.verified_user),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                onSubmitted: (valor) {
                  _codigoEmpresa = valor;
                  print('El codigo de empresa es $_codigoEmpresa');
                },
              ),

              SizedBox(height: 10.0),

              TextField(
                enableInteractiveSelection: false,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Contraseña Empresa',
                  labelText: 'Contraseña Empresa',
                  suffixIcon: Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                onSubmitted: (valor) {
                  _contrasenaEmpresa = valor;
                  print('La contraseña de la empresa es $_contrasenaEmpresa');
                },
              ),

              SizedBox(height: 10.0),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Código Usuario',
                  labelText: 'Código Usuario',
                  suffixIcon: Icon(Icons.verified_user),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                onSubmitted: (valor) {
                  _codigoUsuario = valor;
                  print('el codigo de usuario es $_codigoUsuario');
                },
              ),

              SizedBox(height: 10.0),

              TextField(
                enableInteractiveSelection: false,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Contraseña Usuario',
                  labelText: 'Contraseña Usuario',
                  suffixIcon: Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                onSubmitted: (valor) {
                  _contrasenaUsuario = valor;
                  print('La contraseña del usuario es $_contrasenaUsuario');
                },
              ),

              SizedBox(height: 18.0),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF023E73),
                    foregroundColor: Colors.white70, // Color del texto
                  ),
                  child: Text(
                    'INGRESAR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20.0,
                      fontFamily: 'Montserrat-Medium',
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EntryPoint()),
                    );
                  },

                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
