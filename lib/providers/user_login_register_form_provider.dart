import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:tfg_contactos/services/services.dart';

class UserLoginRegisterFormProvider extends ChangeNotifier {

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  UsersServices usersServices = UsersServices();
  User user = User(
    clave: '', 
    telefono: ''
  );

  bool isValidLogin(String number) {
    bool validate = false;
    int counter = 0;

    print('Fuera del for $counter');
    print('Cantidad de usuarios ' + usersServices.users.length.toString());

    for (var i = 0; i < usersServices.users.length; i++) {
      if(usersServices.users[i].telefono == number) {
        counter++;
      }
      print(usersServices.users[i].id);
      print(usersServices.users[i].telefono);
      print(usersServices.users[i].clave);
      print(counter);
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