import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:tfg_contactos/services/services.dart';

class UserLoginRegisterFormProvider extends ChangeNotifier {

  // Clave para la validación de formularios
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // Instacia del servicio de usuarios
  UsersServices usersServices = UsersServices();
  // Usuario empleado para el registro
  User user = User(
    clave: '', 
    telefono: ''
  );
  // Variable para rastrear si los usuarios se han cargado
  bool _usersLoaded = false; 

  UserLoginRegisterFormProvider(){
    loadUsers();
  }

  // Método para llamar a notifyListeners
  void notifyChanges() {
    notifyListeners();
  }

  // Método que hace uso del método creado en el servicio
  // de Usuarios para cargar estos desde Firebase
  void loadUsers() async {
    // Hacemos uso del método que carga los Usuarios
    await usersServices.loadUsers();
    // Marcamos los usuarios como cargados
    _usersLoaded = true;
    // Notificamos a los consumidores del proveedor sobre el cambio
    notifyListeners(); 
  }

  // Getter para verificar si los usuarios se han cargado
  bool get usersLoaded => _usersLoaded; 

  // Método para validar el inicio de sesión realizado en la aplicación
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

  // Método para validar si el usuario existe o no en BBDD
  // Existen dos posibles casos, que devuelva 0 o que devuelva 1
  // 0: el Usuario no existe, se creará uno nuevo con los datos
  // 1: el Usuario ya existe en BBDD, 
  //    se tomarán esos datos para establecerlos en la app
  int isValidRegister(String number) {
    int result = 0;

    for (var i = 0; i < usersServices.users.length; i++) {
      if(usersServices.users[i].telefono == number) {
        result++;
      }
    }

    return result;
  }

  // Método para obtener un usuario en concreto de BBDD, 
  // este se usará cuando al hacer el registro el usuario 
  // ya exista
  User getUser(String number) {
    for (var i = 0; i < usersServices.users.length; i++) {
      if(usersServices.users[i].telefono == number) {
        user = usersServices.users[i];
      }
    }

    return user;
  }

  // Método para validar el formulario de creación o edición
  // de usuario
  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }
}