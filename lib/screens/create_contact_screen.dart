import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/screens/screens.dart';
import 'package:tfg_contactos/themes/app_themes.dart';
import 'package:tfg_contactos/widgets/widgets.dart';

class CreateContactScreen extends StatelessWidget {
  const CreateContactScreen({Key? key,
    required this.contactsProvider,
    required this.filteredContacts,
  }) : super(key: key);

  final ContactFormProvider contactsProvider;
  final List<MyContact> filteredContacts;

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String nombre = '', telefono = '';
    MyContact contact = MyContact(
      numUsuario: GlobalVariables.user.telefono, 
      nombre: nombre, 
      telefono: telefono,
      borrado: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Contacto'),
        leading: IconButton(
          onPressed: () {
            contactsProvider.notifyChanges();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactsScreen()
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
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
                  int createContactState = comparePhoneNumber(filteredContacts, telefono);
                  if ( createContactState == 1) {
                    PopUp.duplicatedMessage(context, 1);
                  } else {
                    PopUp.okMessage(context, 0).then((_) async {
                      contact.nombre = nombre;
                      contact.telefono = telefono;
                      contactsProvider.contactServices.createContact(contact);
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

int comparePhoneNumber(List<MyContact> filteredContacts, String phoneNumber){
  int status = 0;

  for (var i = 0; i < filteredContacts.length; i++) {
    if(phoneNumber == filteredContacts[i].telefono) {
      status++;
    }
  }
  
  print(status);

  return status;
}