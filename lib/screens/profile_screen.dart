import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/themes/app_themes.dart';
import 'package:provider/provider.dart';
import 'package:tfg_contactos/widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    Key? key,
    required this.usersProvider,
    required this.deviceNumber,
  }) : super(key: key);

  final UserLoginRegisterFormProvider usersProvider;
  final String deviceNumber;
  
  @override
  Widget build(BuildContext context) {
    ContactFormProvider contactsProvider = Provider.of<ContactFormProvider>(context);
    User user = GlobalVariables.user;
    MyContact contact = MyContact(
      numUsuario: '', 
      nombre: '', 
      telefono: '', 
      borrado: 0
    ); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        // Añadimos el botón de retroceso
        leading: AppBarWidgets.addAndProfileWidgets(
          context, 
          3, 
          usersProvider, 
          contactsProvider, 
          GlobalVariables.user.telefono, 
          GlobalVariables.filteredContacts,
          contact
        ),
        // Añadimos el botón de edición
        actions: [
          AppBarWidgets.addAndProfileWidgets(
            context, 
            5, 
            usersProvider, 
            contactsProvider, 
            GlobalVariables.user.telefono, 
            GlobalVariables.filteredContacts,
            contact
          ),
        ],
      ),
      // Contenido de la pantalla
      body: _ProfileScreenBody(user: user),
    );
  }
}

class _ProfileScreenBody extends StatelessWidget {
  const _ProfileScreenBody({
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Texto del usuario
          Container(
            alignment: AlignmentDirectional.center,
            padding: const EdgeInsets.only(top: 10, bottom: 30, left: 5),
            child: const Text(
              'Tu usuario',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Foto del usuario
          const Center(
            child: CircleAvatar(
              maxRadius: 70,
              backgroundImage: AssetImage(
                'assets/user_profile_pic.png'
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.only(left: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono más texto del teléfono
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(
                    'Teléfono: ${user.telefono}',
                    style: const TextStyle(
                      fontSize: 17.50
                    ),
                  ),
                ),
                // Icono más texto de la clave
                ListTile(
                  leading: const Icon(Icons.password),
                  title: Text(
                    'Clave: ${user.clave}',
                    style: const TextStyle(
                      fontSize: 17.50
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}