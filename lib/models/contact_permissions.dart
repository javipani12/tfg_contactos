import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Este enum nos servirá para saber el estado de los permisos
enum CurrentStatus {
  noPermissions,        // Todavía no se han solicitado los permisos
  granted,              // Permitidos
  denied,               // No permitidos
  deniedPermanently,    // No permitidos de manera permanente
}

class ContactPermissions extends ChangeNotifier {
  CurrentStatus _currentStatus = CurrentStatus.noPermissions;

  CurrentStatus get currentStatus => _currentStatus;

  set currentStatus( CurrentStatus value ) {
    if( value != _currentStatus ) {
      _currentStatus = value;
      notifyListeners();
    }
  }

  // Aquí almacenaremos los contactos de manera temporal
  // para posteriormente subirlos a BBDD si es la primera
  // vez que se usa la aplicación
  List<Contact> contacts = [];

  // Variable para saber si la aplicación ya tiene los permisos aceptados
  bool hasPermission = false;

  // Variable que se usará para el control
  // de la carga de contactos
  bool isLoading = true;


  // Método para comprobar si la aplicación ya tiene los 
  // permisos concedidos
  Future<bool> initializeHasPermissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool permission = prefs.getBool('hasPermission') ?? false;

    if(permission) {
      storeContacts();
      hasPermission = permission;
      currentStatus = CurrentStatus.granted;
      return true;
    }

    return false;
  }

  // Método para solicitar los permisos de contactos al usuario
  // y saber en qué estado se encuentran los permisos.
  // Si los permisos ya se han otorgado anteriormente,
  // no se solicitarán de nuevo
  Future<bool> requestContactPermission() async {
    PermissionStatus result;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool permission = prefs.getBool('hasPermission') ?? false;

    if(permission) {
      hasPermission = permission;
      currentStatus = CurrentStatus.granted;
      return true;
    } else {
      result = await Permission.contacts.request();
      if( result == PermissionStatus.granted){
        currentStatus = CurrentStatus.granted;
        prefs.setBool('hasPermission', true);
        permission = prefs.getBool('hasPermission') ?? false;
        hasPermission = permission;
        return true;
      } else if( Platform.isIOS || result == PermissionStatus.permanentlyDenied ) {
        currentStatus = CurrentStatus.deniedPermanently;
        prefs.setBool('hasPermission', false);
        hasPermission = permission;hasPermission = permission;
      } else {
        currentStatus = CurrentStatus.denied;
        prefs.setBool('hasPermission', false);
        hasPermission = permission;
      }
    }

    return false;
  }
  
  // Método para almacenar los contactos que hay en el teléfono
  // si se han otorgado los permisos
  Future<void> storeContacts() async {
    isLoading = true;
    notifyListeners();

    final Iterable<Contact> obtainedContacts = await ContactsService.getContacts();
    contacts = obtainedContacts.toList();

    isLoading = false;
    notifyListeners();
  }
}