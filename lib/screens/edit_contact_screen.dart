import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/screens/screens.dart';
import 'package:tfg_contactos/themes/app_themes.dart';
import 'package:provider/provider.dart';
import 'package:tfg_contactos/widgets/widgets.dart';

class EditContactScreen extends StatelessWidget {

  final MyContact contact;
  final ContactFormProvider contactsProvider;

  const EditContactScreen({
    super.key, 
    required this.contact,
    required this.contactsProvider
  });

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String telefono = '', nombre = '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Contacto'),
        actions: [
          IconButton(
            onPressed: () {
              PopUp.okMessage(context, 2).then((result) async {
                if(result == 1) {
                  contact.borrado = 1;
                  contactsProvider.contactServices.updateContact(contact);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactsScreen()
                    ),
                  );
                } else {
                  Navigator.pop(context);
                }
              });
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              initialValue: contact.nombre,
              onChanged: (value) {
                nombre = value;
              },
              decoration: const InputDecoration(hintText: 'Nombre'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'El nombre no puede estar vacío';
                }
                return null;
              },
            ),
            TextFormField(
              initialValue: contact.telefono,
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                telefono = value;
              },
              decoration: const InputDecoration(hintText: 'Teléfono'),
              validator: (value) {
                if (value!.length != 9) {
                  return 'La longitud debe ser 9';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  int updateContactState = contactsProvider.isValidContact(GlobalVariables.user.telefono, telefono);
                  if ( updateContactState == 1) {
                    PopUp.duplicatedMessage(context, 2);
                  } else {
                    PopUp.okMessage(context, 1).then((_) async {
                      contact.nombre = nombre;
                      contact.telefono = telefono;
                      contactsProvider.contactServices.updateContact(contact);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactsScreen()
                        ),
                      );
                    });
                  }
                }
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}

