import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:tfg_contactos/services/services.dart';

class ContactFormProvider extends ChangeNotifier {

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ContactServices contactServices = ContactServices();
  Contact? contact;

  ContactFormProvider(){
    loadContacts();
  }

  bool _contactsLoaded = false; // Variable para rastrear si los usuarios se han cargado

  void loadContacts() async {
    await contactServices.loadContacts(); // Cargar los usuarios desde algún servicio o fuente de datos
    _contactsLoaded = true; // Marcar los usuarios como cargados
    notifyListeners(); // Notificar a los consumidores del proveedor sobre el cambio
  }

  bool get usersLoaded => _contactsLoaded; // Getter para verificar si los usuarios se han cargado

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }
}