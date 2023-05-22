import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:tfg_contactos/services/services.dart';

class UserLoginRegisterFormProvider extends ChangeNotifier {

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  UsersServices usersServices = UsersServices();
  User user = User(
    clave: '', 
    telefono: ''
  );

  UserLoginRegisterFormProvider(){
    loadUsers();
  }

  bool _usersLoaded = false; // Variable para rastrear si los usuarios se han cargado

  void loadUsers() async {
    await usersServices.loadUsers(); // Cargar los usuarios desde algún servicio o fuente de datos
    _usersLoaded = true; // Marcar los usuarios como cargados
    notifyListeners(); // Notificar a los consumidores del proveedor sobre el cambio
  }

  bool get usersLoaded => _usersLoaded; // Getter para verificar si los usuarios se han cargado

  bool isValidLogin(String number) {
    bool validate = false;
    int counter = 0;

    for (var i = 0; i < usersServices.users.length; i++) {
      if(usersServices.users[i].telefono == number) {
        counter++;
      }
    }

    if(counter == 1) {
      validate = true;
    }
    
    return validate;
  }

  int isValidRegister(String number) {
    int result = 0;

    for (var i = 0; i < usersServices.users.length; i++) {
      if(usersServices.users[i].telefono == number) {
        result++;
      }
    }

    return result;
  }

  User getUser(String number) {
    for (var i = 0; i < usersServices.users.length; i++) {
      if(usersServices.users[i].telefono == number) {
        user = usersServices.users[i];
      }
    }

    return user;
  }
}