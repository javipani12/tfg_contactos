import 'package:flutter/material.dart';

class AppThemes {
  static const Color primary = Colors.blueGrey;


  static final ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: primary,
    appBarTheme: const AppBarTheme(
      color: primary,
      elevation: 0,
    ),

    // Botones de inicio de sesión, registro, reestablecer contraseña, continuar y llamar
    // Por el momento
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        shape: const StadiumBorder(),
        elevation: 2,
        alignment: Alignment.center,
        textStyle: const TextStyle(color: Colors.white),
      ),
    ),

    // Colores de los iconos de la listas
    listTileTheme: const ListTileThemeData(
      iconColor: primary,
    ),

    // TextButton Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
      )
    ),

    // Botón volver hacia atrás
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      elevation: 5,
    ),

    // Campos de formulario
    inputDecorationTheme: const InputDecorationTheme(
      floatingLabelStyle: TextStyle(color: primary),
      // Cuando está activo
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: primary
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(10)
        ),
      ),
      // Cuando tiene el foco
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: primary
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(10)
        ),
      ),
      // Borde del campo
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: primary
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(10)
        ),
      ),
    ),

    // Card
    cardTheme: CardTheme(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),

    // Círculo de carga
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
      circularTrackColor: Color.fromARGB(255, 172, 209, 233),
    ),
  );
}