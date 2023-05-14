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

    factory Contact.fromRawJson(String str) => Contact.fromMap(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Contact.fromMap(Map<String, dynamic> json) => Contact(
        idUsuario: json["idUsuario"],
        nombre: json["nombre"],
        telefono: json["telefono"],
    );

    Map<String, dynamic> toJson() => {
        "idUsuario": idUsuario,
        "nombre": nombre,
        "telefono": telefono,
    };
}
