import 'package:flutter/material.dart';
import 'package:tfg_contactos/screens/screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contactos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ContactScreen(),
    );
  }
}