import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/screens/screens.dart';
import 'package:tfg_contactos/themes/app_themes.dart';
import 'package:provider/provider.dart';
import 'package:tfg_contactos/widgets/global_variables.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
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
        actions: [
          IconButton(
            onPressed: () {
              final route = MaterialPageRoute(
                builder: (context) => EditProfileScreen(
                  usersProvider: usersProvider, 
                  contactsProvider: contactsProvider,
                  user: user,
                ),
              );
              Navigator.push(context, route);
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: _ProfileScreenBody(user: user),
    );
  }
}

class _ProfileScreenBody extends StatelessWidget {
  const _ProfileScreenBody({
    super.key,
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
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    'Teléfono: ${user.telefono}',
                    style: const TextStyle(
                      fontSize: 17.50
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
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