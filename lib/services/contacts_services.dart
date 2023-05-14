import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:http/http.dart' as http;

class ContactServices extends ChangeNotifier {

  final String _baseURL = 'contactos-405d0-default-rtdb.europe-west1.firebasedatabase.app';
  final List<Contact> contacts = [];

  ContactServices(){
    loadContacts();
  }

  Future <List<Contact>> loadContacts() async  {
    final url = Uri.https(_baseURL, 'contactos.json');
    final resp = await http.get(url);

    final Map<String, dynamic> contactsMap = json.decode(resp.body);

    contactsMap.forEach((key, value) {
      final tempContact = Contact.fromMap(value);
      tempContact.id = key;
      contacts.add(tempContact);
    });

    return contacts;
  } 

  Future<String> updateContact(Contact contact) async {
    final url = Uri.https(_baseURL, 'contactos/${contact.id}.json');
    final resp = await http.put(url, body: contact.toJson());
    final decodedData = resp.body;

    final index = contacts.indexWhere((element) => element.id == contact.id);
    contacts[index] = contact;

    return contact.id!;
  }

  Future<String> createContact(Contact contact) async {
    final url = Uri.https(_baseURL, 'usuarios.json');
    final resp = await http.post(url, body: contact.toJson());
    final decodedData = json.decode(resp.body);

    contact.id = decodedData['nombre'];
    contacts.add(contact);

    return contact.id ?? 'default';
  }

}