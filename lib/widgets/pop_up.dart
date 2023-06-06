import 'package:flutter/material.dart';

class PopUp{

  static Future<dynamic> duplicatedMessage(BuildContext context, int state) {
    String firstMessageLine = ' ';
    String message = ' ';

    // El valor de state podrá ser 0, 1 ó 2.
    // 0: Venimos desde el registro.
    // 1: Venimos desde la edición del usuario.
    // 2: Venimos desde la edición de un contacto.
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

  static Future<dynamic> okMessage(BuildContext context, int state) {
    String firstMessageLine = ' ';
    String message = ' ';
    int result = 0;
    
    // El valor de state podrá ser 0, 1 ó 2.
    // 0: Venimos desde crear un contacto.
    // 1: Venimos desde actualizar un contacto.
    // 2: Venimos desde borrar un contacto.
    switch(state){
      case 0:
        firstMessageLine = 'Contacto creado';
        message = 'El contacto se ha creado correctamente';
        break;
      case 1:
        firstMessageLine = 'Contacto actualizado';
        message = 'El contacto se ha actualizado correctamente';
        break;
      case 2:
        firstMessageLine = 'Borrar Contacto';
        message = '¿Estás seguro/a de que quieres borrar este contacto?';
        break;
    }


    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${firstMessageLine}'),
        content: Text('${message}'),
        actions: [
          state == 0 || state == 1 ?
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
          :
          ElevatedButton(
            onPressed: () {
              result = 0;
              Navigator.pop(context, result);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              result = 1;
              Navigator.pop(context, result);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}