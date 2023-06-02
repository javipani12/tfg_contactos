import 'dart:convert';

// Clase que sirve como modelo para adaptar la tabla 
// de Contactos de Firebase a código
class MyContact {
    String numUsuario;
    String nombre;
    String telefono;
    String? id;

    MyContact({
        required this.numUsuario,
        required this.nombre,
        required this.telefono,
        this.id,
    });

    factory MyContact.fromJson(String str) => MyContact.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory MyContact.fromMap(Map<String, dynamic> json) => MyContact(
        numUsuario: json["numUsuario"],
        nombre: json["nombre"],
        telefono: json["telefono"],
    );

    Map<String, dynamic> toMap() => {
        "numUsuario": numUsuario,
        "nombre": nombre,
        "telefono": telefono,
    };
}
