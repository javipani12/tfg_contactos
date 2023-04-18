import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Este enum nos servirá para saber el estado de los permisos
enum CurrentStatus {
  granted,              // Permitidos
  denied,               // No permitidos
  deniedPermanently,    // No permitidos de manera permanente
  storedContacs,        // Los contactos han sido guardados
}

class ContactPermissions extends ChangeNotifier {
  CurrentStatus _currentStatus = CurrentStatus.denied;

  CurrentStatus get currentStatus => _currentStatus;

  set currentStatus( CurrentStatus value ) {
    if( value != _currentStatus ) {
      _currentStatus = value;
      notifyListeners();
    }
  }

  // Aquí almacenaremos los contactos de manera temporal
  // para posteriormente subirlos a BBDD 
  List<Contact>? contacts;

  // Método para solicitar los permisos de contactos al usuario
  // y saber en qué estado se encuentran los permisos
  Future<bool> requestContactPermission() async {
    PermissionStatus result;

    result = await Permission.contacts.request();
    
    if( result.isGranted ){
      currentStatus = CurrentStatus.granted;
      return true;
    } else if( Platform.isIOS || result.isPermanentlyDenied ) {
      currentStatus = CurrentStatus.deniedPermanently;
    } else {
      currentStatus = CurrentStatus.denied;
    }

    return false;
  }
  
  // Método para almacenar los contactos que hay en el teléfono
  // si se han otorgado los permisos
  Future<void> storeContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(currentStatus == CurrentStatus.granted) {
      prefs.setBool('hasPermission', true);
      final Iterable<Contact> obtainedContacts = await ContactsService.getContacts();
      contacts = obtainedContacts.toList();
      currentStatus = CurrentStatus.storedContacs;
    }
  }
}