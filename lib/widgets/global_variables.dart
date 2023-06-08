import 'package:tfg_contactos/models/models.dart';

class GlobalVariables {

  // Variable global del Usuario
  static User user = User(
    clave: '', 
    telefono: ''
  );

  // Variable globar de la lista de contactos
  // filtrada para un usuario en específico
  static List<MyContact> filteredContacts = [];
}