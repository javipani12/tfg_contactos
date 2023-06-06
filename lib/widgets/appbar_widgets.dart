import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/screens/screens.dart';

class AppBarWidgets {

  // Método para rellenar los Widgets que irán 
  // en el AppBar
  static Widget addAndProfileWidgets(
      BuildContext context, 
      int position, 
      UserLoginRegisterFormProvider userProvider, 
      ContactFormProvider contactsProvider, 
      String deviceNumber,
      List<MyContact> filteredContacts
    ){
    
    Widget widget = Container();

    switch(position){
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
          icon: const Icon(Icons.settings),
        );
        break;
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
      case 2:
        widget = IconButton(
          onPressed: () {
            final route = MaterialPageRoute(
              builder: (context) => ContactsScreen(),
            );
            Navigator.push(context, route);
          },
          icon: const Icon(Icons.delete),
        );
        break;
    }

    return widget;   
  }
}