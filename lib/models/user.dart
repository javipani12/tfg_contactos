import 'dart:convert';

class User {
    String clave;
    String telefono;
    String? id;

    User({
        required this.clave,
        required this.telefono,
        this.id,
    });

    factory User.fromJson(String str) => User.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory User.fromMap(Map<String, dynamic> json) => User(
        clave: json["clave"],
        telefono: json["telefono"],
    );

    Map<String, dynamic> toMap() => {
        "clave": clave,
        "telefono": telefono,
    };
}