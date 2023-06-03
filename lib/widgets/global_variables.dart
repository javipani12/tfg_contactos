import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';

class GlobalVariables {

  static User user = User(
    clave: '', 
    telefono: ''
  );

  static List<MyContact> filteredContacts = [];
}