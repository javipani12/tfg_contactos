import 'package:flutter/material.dart';

class PopUp{

  static Future<dynamic> duplicatedMessage(BuildContext context, int state) {
    String firstMessageLine = ' ';
    String message = ' ';

    // El valor de state podrá ser 0, 1 ó 2.
    // 0: Venimos desde el registro.
    // 1: Venimos desde la edición del usuario
    // 2: El contacto ya existe en la lista de contactos del usuario
    switch(state) {
      case 0:
        firstMessageLine = 'El número de teléfono ya existe, ';
        message = 'se procederá a cargar los contactos que tiene asociados.';
        break;
      case 1:
        firstMessageLine = 'El número de teléfono ya existe, ';
        message = 'prueba a establecer otro número de teléfono';
        break;
      case 2:
        firstMessageLine = 'El contacto ya existe en tu lista, ';
        message = 'prueba a crear otro diferente ';
    }

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Número existente'),
        content: Text('$firstMessageLine' 
        '$message'
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static Future<dynamic> okMessage(BuildContext context) {

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacto creado'),
        content: const Text('El contacto se ha creado correctamente'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}