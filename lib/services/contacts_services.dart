import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:http/http.dart' as http;

class ContactServices extends ChangeNotifier {

  // URL de nuestra BBDD de Firebase
  final String _baseURL = 'contactos-405d0-default-rtdb.europe-west1.firebasedatabase.app';
  // Lista que almacenará los Contactos cargados de BBDD
  final List<MyContact> contacts = [];

  // Método para cargar los Contactos de BBDD en la lista
  Future <List<MyContact>> loadContacts() async  {
    final url = Uri.https(_baseURL, 'contactos.json');
    final resp = await http.get(url);

    final Map<String, dynamic> contactsMap = json.decode(resp.body);

    contactsMap.forEach((key, value) {
      final tempContact = MyContact.fromMap(value);
      tempContact.id = key;
      contacts.add(tempContact);
    });

    return contacts;
  } 

  // Método para actualizar un Contacto mediante 
  // el uso del id
  Future<String> updateContact(MyContact contact) async {
    final url = Uri.https(_baseURL, 'contactos/${contact.id}.json');
    final resp = await http.put(url, body: contact.toJson());
    final decodedData = resp.body;

    final index = contacts.indexWhere((element) => element.id == contact.id);
    contacts[index] = contact;

    return contact.id!;
  }

  // Método para crear un contacto en BBDD
  Future<String> createContact(MyContact contact) async {
    final url = Uri.https(_baseURL, 'contactos.json');
    final resp = await http.post(url, body: contact.toJson());
    final decodedData = json.decode(resp.body);

    contact.id = decodedData['name'];
    contacts.add(contact);

    return contact.id ?? 'default';
  }

}