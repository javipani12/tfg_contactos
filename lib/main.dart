import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/screens/screens.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserLoginRegisterFormProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (context) => ContactFormProvider(),
          lazy: false,
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contactos',
      routes: {
        'loginRegister':(context) => LoginRegisterScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginRegisterScreen(),
    );
  }
}