import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class ContactScreen extends StatelessWidget {
  final MyContact contact;
  final String userProfilePic;

  const ContactScreen({
    super.key, 
    required this.contact,
    required this.userProfilePic,
  });

  @override
  Widget build(BuildContext context) {
    ContactFormProvider contactsProvider = Provider.of<ContactFormProvider>(context);
    UserLoginRegisterFormProvider usersProvider = Provider.of<UserLoginRegisterFormProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.nombre),
        // Flecha de retroceso
        leading: AppBarWidgets.addAndProfileWidgets(
          context, 
          3, 
          usersProvider, 
          contactsProvider, 
          GlobalVariables.user.telefono, 
          GlobalVariables.filteredContacts,
          contact,
          userProfilePic
        ),
        actions: [
          // Botón de editar
          AppBarWidgets.addAndProfileWidgets(
            context, 
            4, 
            usersProvider, 
            contactsProvider, 
            GlobalVariables.user.telefono, 
            GlobalVariables.filteredContacts,
            contact,
            userProfilePic
          ),
          // Botón de borrado
          AppBarWidgets.addAndProfileWidgets(
            context, 
            2, 
            usersProvider, 
            contactsProvider, 
            GlobalVariables.user.telefono, 
            GlobalVariables.filteredContacts,
            contact,
            userProfilePic
          ),
        ],
      ),
      // Cuerpo de la ventana
      body: _ContactScreenBody(
        contact: contact,
        contactsProvider: contactsProvider,
        userProfilePic: userProfilePic,
      ),
    );
  }
}

class _ContactScreenBody extends StatelessWidget {
  final MyContact contact;
  final ContactFormProvider contactsProvider;
  final String userProfilePic;

  const _ContactScreenBody({
    required this.contact,
    required this.contactsProvider,
    required this.userProfilePic,
  });

  @override
  Widget build(BuildContext context) {
    String whatsappURL = "https://wa.me/${contact.telefono}";

    return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        // Imagen del contacto
        Center(
          child: CircleAvatar(
            maxRadius: 80,
            backgroundImage: AssetImage(
              userProfilePic
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          margin: const EdgeInsets.only(left: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono más texto del nombre
              ListTile(
                leading: const Icon(
                  Icons.person,
                  size: 40,
                ),
                title: Text(
                  'Nombre: ${contact.nombre}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              // Icono más texto del teléfono
              ListTile(
                leading: const Icon(
                  Icons.phone,
                  size: 40,
                ),
                title: Text(
                  'Teléfono: ${contact.telefono}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  // Icono para ir a Whatsapp
                  Column(
                    children: [
                      const Text(
                        'Ir a Whatsapp',
                        style: TextStyle(
                          fontSize: 20
                        ),
                      ),
                      IconButton(
                        color: Colors.green,
                        iconSize: 70,
                        icon: const ImageIcon(
                          NetworkImage(
                            'https://i.pinimg.com/originals/90/22/c3/9022c3da331305796ded3dda4c619df0.png'
                          ),
                        ),
                        onPressed: () async => {
                          if(await canLaunchUrl(Uri.parse(whatsappURL))){
                            await launchUrl(Uri.parse(whatsappURL), mode: LaunchMode.externalApplication)
                          }
                        }
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  // Icono para la llamada
                  Column(
                    children: [
                      const Text(
                        'Llamar',
                        style: TextStyle(
                          fontSize: 20
                        ),
                      ),
                      IconButton(
                        color: Colors.green,
                        iconSize: 70,
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
            ],
          ),
        ),
      ],
    ),
    );
  }
}