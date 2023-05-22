import 'dart:convert';

class Contact {
    int idUsuario;
    String nombre;
    String telefono;
    String? id;

    Contact({
        required this.idUsuario,
        required this.nombre,
        required this.telefono,
        this.id,
    });

    factory Contact.fromJson(String str) => Contact.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Contact.fromMap(Map<String, dynamic> json) => Contact(
        idUsuario: json["idUsuario"],
        nombre: json["nombre"],
        telefono: json["telefono"],
    );

    Map<String, dynamic> toMap() => {
        "idUsuario": idUsuario,
        "nombre": nombre,
        "telefono": telefono,
    };
}
