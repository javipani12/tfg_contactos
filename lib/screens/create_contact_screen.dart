import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    UserLoginRegisterFormProvider usersProvider = Provider.of<UserLoginRegisterFormProvider>(context);
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
        leading:AppBarWidgets.addAndProfileWidgets(
          context, 
          3, 
          usersProvider, 
          contactsProvider, 
          GlobalVariables.user.telefono, 
          GlobalVariables.filteredContacts,
          contact
        ),
      ),
      // Formulario para la creación de un contacto
      body: Form(
        key: formKey,
        child: Column(
          children: [
            // Campo del nombre
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
            // Campo del teléfono
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
            // Botón para la creación del contacto
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  int createContactState = comparePhoneNumber(filteredContacts, telefono);
                  // Si ya existe el teléfono, mensaje de error
                  if ( createContactState == 1) {
                    PopUp.duplicatedMessage(context, 1);
                  } else {
                    // En caso contrario, mensaje de todo correcto
                    PopUp.okMessage(context, 0).then((_) async {
                      contact.nombre = nombre;
                      contact.telefono = telefono;
                      contactsProvider.contactServices.createContact(contact);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactsScreen()
                        ),
                      );
                    });
                  }
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }
}

// Método que compara el número de teléfono del contacto
// con los teléfonos de la lista de contactos filtrada
// para el usuario.
// Puede devolver dos estados:
// 0: No existe
// 1: Existe
int comparePhoneNumber(List<MyContact> filteredContacts, String phoneNumber){
  int status = 0;

  for (var i = 0; i < filteredContacts.length; i++) {
    if(phoneNumber == filteredContacts[i].telefono) {
      status++;
    }
  }

  return status;
}