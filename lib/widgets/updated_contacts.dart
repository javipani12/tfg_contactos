import 'package:shared_preferences/shared_preferences.dart';

class UpdatedContacts {

  // Método para establecer una variable al dispositivo 
  // cuando se han subido los contactos desde el Registro
  static Future<void> setUpdatedContacts(String updatedContacts) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('updatedContacts', updatedContacts);
  }

  // Método para obtener la variable que indica
  // si el dispositivo ya ha subido los contactos 
  // desde el registro 
  static Future<String> getUpdatedContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String updatedContacts = prefs.getString('updatedContacts') ?? '';

    return updatedContacts;
  }
}