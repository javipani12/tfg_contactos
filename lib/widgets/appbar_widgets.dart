import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/screens/screens.dart';
import 'package:tfg_contactos/widgets/widgets.dart';

class AppBarWidgets {

  // Método para rellenar los Widgets que irán 
  // en el AppBar
  static Widget addAndProfileWidgets(
      BuildContext context, 
      int position, 
      UserLoginRegisterFormProvider userProvider, 
      ContactFormProvider contactsProvider, 
      String deviceNumber,
      List<MyContact> filteredContacts,
      MyContact contact,
  ) {
    Widget widget = Container();

    switch(position){
      // Botón para perfil de usuario (ContactsScreen)
      case 0:
        widget = IconButton(
          onPressed: () {
            final route = MaterialPageRoute(
              builder: (context) => ProfileScreen(
                usersProvider: userProvider, 
                deviceNumber: deviceNumber,
              ),
            );
            Navigator.push(context, route);
          },
          icon: const Icon(Icons.person),
        );
        break;
      // Botón para crear un usuario (ContactsScreen)
      case 1:
        widget = IconButton(
          onPressed: () {
            final route = MaterialPageRoute(
              builder: (context) => CreateContactScreen(
                contactsProvider: contactsProvider,
                filteredContacts: filteredContacts,
              ),
            );
            Navigator.push(context, route);
          },
          icon: const Icon(Icons.add),
        );
        break;
      // Botón de borrado de un contacto (ContactScreen)
      case 2:
        widget = IconButton(
          onPressed: () {
            PopUp.okMessage(context, 3).then((result) async {
              if(result == 1) {
                contact.borrado = 1;
                contactsProvider.contactServices.updateContact(contact);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactsScreen()
                  ),
                );
              }
            });
          },
          icon: const Icon(Icons.delete),
        );
        break;
      // Botón de retroceso al ContactsScreen (ContactScreen,
      // CreateContactScreen y ProfileScreen)
      case 3:
        widget = IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactsScreen()
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        );
        break;
      // Botón para editar un contacto (ContactScreen)
      case 4:
        widget = IconButton(
          onPressed: () {
            final route = MaterialPageRoute(
              builder: (context) => EditContactScreen(
                contact: contact,
                contactsProvider: contactsProvider,
              )
            );
            Navigator.push(context, route);
          },
          icon: const Icon(Icons.edit),
        );
        break;
      // Botón para editar el perfil (ProfileScreen)
      case 5:
        widget = IconButton(
          onPressed: () {
            final route = MaterialPageRoute(
              builder: (context) => EditProfileScreen(
                usersProvider: userProvider, 
                contactsProvider: contactsProvider,
                user: GlobalVariables.user,
              ),
            );
            Navigator.push(context, route);
          },
          icon: const Icon(Icons.edit),
        );
        break;
    }

    return widget;   
  }
}