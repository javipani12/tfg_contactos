import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:tfg_contactos/services/services.dart';

class ContactFormProvider extends ChangeNotifier {

  // Clave para la validación del formulario
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // Instancia del servicio de Contactos
  ContactServices contactServices = ContactServices();
  MyContact? contact;

  ContactFormProvider(){
    loadContacts();
  }

  // Método para llamar a notifyListeners
  void notifyChanges() {
    notifyListeners();
  }

  // Variable para rastrear si los Contactos se han cargado
  bool _contactsLoaded = false; 

  // Método que hace uso del método del servicio de Contactos
  // para cargar estos desde BBDD
  void loadContacts() async {
    await contactServices.loadContacts();
    // Marcamos los Contactos como cargados
    _contactsLoaded = true;
    // Notificamos a los consumidores del proveedor 
    // sobre el cambio 
    notifyListeners();
  }

  // Getter para verificar si los contactos se han cargado
  bool get usersLoaded => _contactsLoaded; 

  // Método para validar el formulario de creación o edición
  // de usuario
  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  // Método para comprobar si el contacto
  // ya existe en BBDD asociado a un usuario
  // en concreto.
  // Puede devolver 2 estados:
  // 0: No existe en BBDD
  // 1: Existe en BBDD
  int isValidContact(String deviceNumber, String newPhoneNumber){
    int state = 0;

    for (var i = 0; i < contactServices.contacts.length; i++) {
      if(contactServices.contacts[i].numUsuario == deviceNumber &&
        contactServices.contacts[i].telefono == newPhoneNumber)
      {
        state = 1;  
      }
    }

    return state;
  }
}