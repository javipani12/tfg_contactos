import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:http/http.dart' as http;

class UsersServices extends ChangeNotifier {

  // URL de la BBDD
  final String _baseURL = 'contactos-405d0-default-rtdb.europe-west1.firebasedatabase.app';
  // Lista donde se almacenarán los usuarios de la BBDD
  final List<User> users = [];

  // Constructor de la clase
  UsersServices(){
    loadUsers();
  }

  // Método para cargar los usuarios de BBDD 
  Future <List<User>> loadUsers() async  {
    final url = Uri.https(_baseURL, 'usuarios.json');
    final resp = await http.get(url);

    final Map<String, dynamic> usersMap = json.decode(resp.body);

    usersMap.forEach((key, value) {
      final tempUser = User.fromMap(value);
      tempUser.id = key;
      users.add(tempUser);
    });

    return users;
  }

  // Método para actualizar un usuario en concreto mediante el uso
  // de su id
  Future<String> updateUser(User user) async {
    final url = Uri.https(_baseURL, 'usuarios/${user.id}.json');
    final resp = await http.put(url, body: user.toJson());
    final decodedData = resp.body;

    final index = users.indexWhere((element) => element.id == user.id);
    users[index] = user;

    return user.id!;
  }

  // Método para la creación de un usuario en BBDD
  Future<String> createUser(User user) async {
    final url = Uri.https(_baseURL, 'usuarios.json');
    final resp = await http.post(url, body: user.toJson());
    final decodedData = json.decode(resp.body);

    user.id = decodedData['telefono'];
    users.add(user);

    return user.id ?? 'default';
  }

}