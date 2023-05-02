import 'package:shared_preferences/shared_preferences.dart';

class DeviceToken {

  // Método para establecer el token al dispositivo la primera vez que se usa
  // de manera que pueda identificarse en BBDD
  static Future<void> setToken( String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('deviceNumber', phoneNumber);
  }

  // Método para comprobar si el dispositivo ya tiene un token asignado
  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phoneNumber = prefs.getString('deviceNumber') ?? '';

    return phoneNumber;
  }


}