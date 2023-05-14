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

    factory User.fromRawJson(String str) => User.fromMap(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory User.fromMap(Map<String, dynamic> json) => User(
        clave: json["clave"],
        telefono: json["telefono"],
    );

    Map<String, dynamic> toJson() => {
        "clave": clave,
        "telefono": telefono,
    };
}
