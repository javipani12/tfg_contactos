import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/screens/screens.dart';
import 'package:tfg_contactos/widgets/widgets.dart';
import 'package:tfg_contactos/themes/app_themes.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class ContactScreen extends StatelessWidget {
  final MyContact contact;

  const ContactScreen({
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    ContactFormProvider contactsProvider = Provider.of<ContactFormProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        leading: IconButton(
          onPressed: () {
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
                builder: (context) => EditContactScreen(
                  contact: contact,
                  contactsProvider: contactsProvider,
                )
              );
              Navigator.push(context, route);
            },
            icon: const Icon(Icons.edit),
          ),
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
      body: _ContactScreenBody(
        contact: contact,
        contactsProvider: contactsProvider,
      ),
    );
  }
}

class _ContactScreenBody extends StatelessWidget {
  final MyContact contact;
  final ContactFormProvider contactsProvider;

  const _ContactScreenBody({
    super.key,
    required this.contact,
    required this.contactsProvider
  });

  @override
  Widget build(BuildContext context) {
    String whatsappURL = '';

    if(Platform.isIOS) {

    } else {
      whatsappURL = "https://wa.me/${contact.telefono}";
    }

    return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
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
                  'Nombre: ${contact.nombre}',
                  style: const TextStyle(
                    fontSize: 17.50
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: Text(
                  'Teléfono: ${contact.telefono}',
                  style: const TextStyle(
                    fontSize: 17.50
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    color: Colors.green,
                    iconSize: 50,
                    icon: const ImageIcon(
                      NetworkImage(
                        'https://i.pinimg.com/originals/90/22/c3/9022c3da331305796ded3dda4c619df0.png'
                      ),
                    ),
                    onPressed: () async => {
                      if(await canLaunchUrl(Uri.parse(whatsappURL))){
                        await launchUrl(Uri.parse(whatsappURL),mode: LaunchMode.externalApplication)
                      }
                    }
                  ),
                  IconButton(
                    color: Colors.green,
                    iconSize: 50,
                    icon: const Icon(Icons.phone),
                    onPressed: () async => {
                      await FlutterPhoneDirectCaller.callNumber(
                        contact.telefono
                      ),
                    }
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
    );
  }
}