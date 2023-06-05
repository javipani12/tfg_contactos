import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/screens/screens.dart';
import 'package:tfg_contactos/themes/app_themes.dart';
import 'package:provider/provider.dart';
import 'package:tfg_contactos/widgets/widgets.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({
    Key? key,
    required this.usersProvider,
    required this.user,
  }) : super(key: key);

  final UserLoginRegisterFormProvider usersProvider;
  final User user;

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    ContactFormProvider contactsProvider = Provider.of<ContactFormProvider>(context);
    String telefono = '', clave = '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              initialValue: user.telefono,
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
            TextFormField(
              initialValue: user.clave,
              onChanged: (value) {
                clave = value;
              },
              decoration: const InputDecoration(hintText: 'Clave'),
              validator: (value) {
                if (value!.length != 5) {
                  return 'La longitud debe ser 5';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  int updateUserState = usersProvider.isValidRegister(telefono);
                  if ( updateUserState == 1) {
                    PopUp.duplicatedMessage(context, 1);
                  } else {
                    user.telefono = telefono;
                    user.clave = clave;
                    await DeviceNumber.setNumber(user.telefono);
                    await DevicePass.setPass(user.clave);
                    GlobalVariables.user = user;
                    updateContacNumUser(contactsProvider);
                    usersProvider.usersServices.updateUser(user);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          usersProvider: usersProvider, 
                          deviceNumber: user.telefono,
                        )
                      ),
                    );
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

// Método para actualizar el numUsuario a los contactos
// del usuario
void updateContacNumUser(ContactFormProvider contactsProvider) {
  for (var i = 0; i < GlobalVariables.filteredContacts.length; i++) {
    GlobalVariables.filteredContacts[i].numUsuario = GlobalVariables.user.telefono;
    contactsProvider.contactServices.updateContact(GlobalVariables.filteredContacts[i]);
  }

  contactsProvider.notifyChanges();
}