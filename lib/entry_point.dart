import 'dart:math';
import 'package:autogestion/components/side_menu.dart';
import 'package:autogestion/screens/home/inicio_screen.dart';
import 'package:autogestion/src/login.dart';
import 'package:autogestion/utils/constants.dart';
import 'package:flutter/material.dart';
import 'models/menu_btn.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> animation;
  late Animation<double> scalAnimation;
  bool isSideMenuClosed = true;
  Widget currentView = InicioScreen(appBarTitle: "Inicio", appBarIcon: Icons.home); // Inicialmente se muestra HomePage

  @override
  void initState() {

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {});
      });
    bool isSideMenuVisible = true;
    animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animationController, curve: Curves.fastOutSlowIn));
    scalAnimation = Tween<double>(begin: 1, end: .8).animate(CurvedAnimation(parent: _animationController, curve: Curves.fastOutSlowIn));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void changeView(Widget view) {
    setState(() {
      currentView = view;
    });
    _animationController.reverse();
    setState(() {
      print('SDAÑASHDASLDHJLASHDKHASDH');
      this.isSideMenuClosed = false;
    });
  }
  void hideSideMenu() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginForm()), // Navega a LoginForm
          (route) => false, // Elimina todas las rutas anteriores
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor2,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            width: 288,
            left: isSideMenuClosed ? -288 : 0,
            height: MediaQuery.of(context).size.height,
            child: SideMenu(
              onMenuItemClicked: (Widget view) {
                changeView(view); // Cambiar la vista cuando se selecciona un elemento del menú
                _animationController.reverse(); // Cerrar el menú después de seleccionar
                setState(() {
                  isSideMenuClosed = true;
                });
              },
              onExitOptionClicked: hideSideMenu,
            ),
          ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(animation.value - 30 * animation.value * pi / 180),
            child: Transform.translate(
              offset: Offset(animation.value * 265, 0),
              child: Transform.scale(
                scale: scalAnimation.value,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  child: currentView, // Usar currentView en lugar de HomePage
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            left: isSideMenuClosed ? 0 : 220,
            top: 16,
            child: MenuBtn(
              press: () {
                if (isSideMenuClosed) {
                  _animationController.forward();
                  print("ABRIENDOSE");
                } else {
                  _animationController.reverse();
                  print("CERRADO");
                }
                setState(() {
                  isSideMenuClosed = !isSideMenuClosed;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
