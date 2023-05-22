import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';

class ContactFormProvider extends ChangeNotifier {

  GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  Contact? contact;

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }
}