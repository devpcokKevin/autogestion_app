import 'package:autogestion/src/app.dart';
import 'package:flutter/material.dart';

import 'components/side_menu.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'App Login',
        home: const SideMenu(),
    );
  }
}