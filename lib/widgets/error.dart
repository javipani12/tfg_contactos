import 'package:flutter/material.dart';

// Pantalla creada para mostrar el error ocurrido
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    Key? key,
    required this.errorCode,
  }) : super(key: key);

  final int errorCode;

  @override
  Widget build(BuildContext context) {

    // Posibles códigos de errores:
    // 1: El dato persistente de la aplicación no se ha cargado bien
    // 2: El dato persistente almacenado en la aplicación 
    //    no coincide con ninguno en Firebase
    // 3: No se han podido cargar correctamente los contactos
    //    desde Firebase

    String errorMessage = '';
    switch(errorCode) {
      case 1:
        errorMessage = 'Se ha producido un error al cargar '
                        'el número de teléfono del dispositivo';
        break;
      case 2:
        errorMessage = 'El número de teléfono del dispositivo '
                        'no coincide con los existentes';
        break;
      case 3:
        errorMessage = 'Por algún motivo no se han podido '
                        'cargar correctamente los contactos';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 24.0,
                right: 16.0,
              ),
              child: Text(
                'Se ha producido un error',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 24.0,
                right: 16.0,
              ),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
              ),
            ),
          ]
        )
      )
    );
  }
}