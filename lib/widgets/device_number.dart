import 'package:shared_preferences/shared_preferences.dart';

class DeviceNumber {

  // Método para establecer el teléfono al dispositivo la primera vez que se usa
  // de manera que pueda identificarse en BBDD
  static Future<void> setNumber(String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('deviceNumber', phoneNumber);
  }

  // Método para obtener el teléfono asignado al dispositivo
  static Future<String> getNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phoneNumber = prefs.getString('deviceNumber') ?? '';

    return phoneNumber;
  }

}