import 'package:flutter/material.dart';

class PopUp{

  static Future<dynamic> duplicatedMessage(BuildContext context, int state) {
    String firstMessageLine = '';
    String message = '';

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
            style: const ButtonStyle(
              minimumSize: MaterialStatePropertyAll(
                Size(100, 40)
              )
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  static Future<dynamic> okMessage(BuildContext context, int state) {
    String firstMessageLine = '';
    String message = '';
    int result = 0;
    
    // El valor de state podrá ser 0, 1, 2 ó 3.
    // 0: Venimos desde crear un contacto.
    // 1: Venimos desde actualizar un contacto.
    // 2: Venimos desde actualizar el usuario
    // 3: Venimos desde borrar un contacto.
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
        firstMessageLine = 'Usuario actualizado';
        message = 'Tu usuario se ha actualizado correctamente';
        break;
      case 3:
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
          if (state != 3)
            ElevatedButton(
              onPressed: () {
                result = 1;
                Navigator.pop(context, result);
              },
              style: const ButtonStyle(
                minimumSize: MaterialStatePropertyAll(
                  Size(100, 40)
                )
              ),
              child: const Text('Continuar'),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Si pulsamos en Cancelar devolverá 0
                ElevatedButton(
                  onPressed: () {
                    result = 0;
                    Navigator.pop(context, result);
                  },
                  style: const ButtonStyle(
                    minimumSize: MaterialStatePropertyAll(
                      Size(100, 40)
                    )
                  ),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(
                  width: 10,
                ),
                // Si pulsamos en Confirmar devolverá 1
                ElevatedButton(
                  onPressed: () {
                    result = 1;
                    Navigator.pop(context, result);
                  },
                  style: const ButtonStyle(
                    minimumSize: MaterialStatePropertyAll(
                      Size(100, 40)
                    )
                  ),
                  child: const Text('Confirmar'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}