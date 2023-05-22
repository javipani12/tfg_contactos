import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_contactos/screens/screens.dart';
import 'package:tfg_contactos/services/services.dart';

void main() async {
  runApp(AppState());
}

class AppState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UsersServices(),
        )
      ],
      child: MyApp(),
    );
  }
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
      home: const LoginRegisterScreen(),
    );
  }
}