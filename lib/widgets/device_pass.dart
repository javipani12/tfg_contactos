import 'package:shared_preferences/shared_preferences.dart';

class DevicePass {

  // Método para establecer la clave al dispositivo 
  // la primera vez que se usa
  static Future<void> setPass( String pass) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('devicePass', pass);
  }

  // Método para obtener la clave del dispositivo
  static Future<String> getPass() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String pass = prefs.getString('devicePass') ?? '';

    return pass;
  }


}