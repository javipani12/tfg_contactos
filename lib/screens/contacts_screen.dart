import 'dart:math';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/screens/screens.dart';
import 'package:tfg_contactos/services/services.dart';
import 'package:tfg_contactos/widgets/updated_contacts.dart';
import 'package:tfg_contactos/widgets/widgets.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:restart_app/restart_app.dart';
import 'dart:core';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key,}) : super(key: key);
  
  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> with WidgetsBindingObserver{
  // Variables que necesitaremos para la ejecución de esta pantalla
  late final ContactPermissions _permissions;
  String deviceNumber = GlobalVariables.user.telefono;
  List<Contact> deviceContacts = [];
  bool hasPermission = false;
  bool _detectPermission = false;
  String updatedContacts = '';
  MyContact contact = MyContact(
    numUsuario: '', 
    nombre: '', 
    telefono: '', 
    borrado: 0
  );  

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _permissions = ContactPermissions();
    initializeHasPermissions();
  }

  @override dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Este código se usa cuando el usuario ha denegado los
  // permisos de manera permanente. Detecta si los permisos se han
  // otorgado cuando el usuario vuelve de la pantalla
  // del sistema de permisos
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed &&
      _detectPermission && 
      (_permissions.currentStatus == CurrentStatus.deniedPermanently)) {
        _detectPermission = false;
        _permissions.requestContactPermission();
    } else if(state == AppLifecycleState.paused &&
        _permissions.currentStatus == CurrentStatus.deniedPermanently) {
      _detectPermission = true;
    }
  }

  // Método para inicializar hasPermission, de manera
  // que podemos saber el estado de los permisos
  // desde que inicia la aplicación
  Future<void> initializeHasPermissions() async {
    hasPermission = await _permissions.initializeHasPermissions();
    if(hasPermission){
      deviceContacts = _permissions.contacts;
    }
  }

  // Método para inicializar hasPermission, de manera
  // que podemos saber el estado de los permisos
  // desde que inicia la aplicación
  Future<void> initializeUpdatedContacts() async {
    updatedContacts = await UpdatedContacts.getUpdatedContacts();
  }

  // Método que solicita los permisos al usuario, 
  // si este los otorga, se cargan los contactos
  Future<void> _checkPermissions() async {
    final hasContactPermission = await _permissions.requestContactPermission();
    if(hasContactPermission) {
      try {
        deviceContacts = await _permissions.storeContacts();
      } on Exception catch (e) {
        debugPrint('Error al cargar los contactos: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    UserLoginRegisterFormProvider usersProvider = Provider.of<UserLoginRegisterFormProvider>(context);
    ContactFormProvider contactsProvider = Provider.of<ContactFormProvider>(context);
    Widget addContact = Container();
    Widget profile = Container();

    return ChangeNotifierProvider.value(
      value: _permissions,
      child: Consumer<ContactPermissions>(
        builder: (context, value, child) {
          Widget widget;

          // Comprobamos todos los posibles casos, en función
          // del que sea, el widget será uno u otro
          // Si ya tiene los permisos con anterioridad, quiere
          // decir que se accede desde el login
          if(hasPermission) {
            GlobalVariables.filteredContacts = filterContacts(contactsProvider, deviceNumber);
            profile = AppBarWidgets.addAndProfileWidgets(context, 0, usersProvider, contactsProvider, deviceNumber, GlobalVariables.filteredContacts, contact, '');
            addContact = AppBarWidgets.addAndProfileWidgets(context, 1, usersProvider, contactsProvider, deviceNumber, GlobalVariables.filteredContacts, contact, '');
            widget = ContactsLoaded(contacts: GlobalVariables.filteredContacts);
          } else {
            // Si no tenemos los permisos con anterioridad
            // quiere decir que entramos desde el registro
            switch(value.currentStatus) {
              case CurrentStatus.noPermissions:
                widget = LoadContactsButton(onPressed: _checkPermissions);
                break;
              case CurrentStatus.denied:
                widget = AskPermissionsButton(isPermanent: false, onPressed: _checkPermissions);
                break;
              case CurrentStatus.deniedPermanently:
                widget = AskPermissionsButton(isPermanent: true, onPressed:  _checkPermissions);
                break;
              case CurrentStatus.granted:
                // Cuando se han otorgado los permisos
                // subimos los contactos a BBDD y reiniciamos la app
                uploadContacts(creatMyContactsList(deviceContacts, contactsProvider, deviceNumber, updatedContacts), contactsProvider);
                widget = const RestartApp();
                break;
            }
          }
          
          return Scaffold(
            appBar: AppBar(
              title: const Text('Contactos'),
              automaticallyImplyLeading: false,
              actions: [
                // Añadimos lo botones del AppBar,
                // solo aparecerán cuando accedemos desde el login
                addContact,
                profile,
              ],
            ),
            body: FutureBuilder<void>(
              // Agrega un retraso de inicio de 2 segundos
              future: Future.delayed(const Duration(seconds: 1)), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Mostramos un indicador de carga mientras esperamos
                  return const Center(
                    child: CircularProgressIndicator()
                  );
                } else {
                  // El retraso ha finalizado, mostramos el contenido del cuerpo
                  return widget;
                }
              },
            ),
          );
        },
      )
    );
  }
}

// Widget para Reiniciar la aplicación
// la primera vez que se usa
class RestartApp extends StatelessWidget {
  const RestartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
            ),
            child: const Text(
              'Contactos Cargados',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 20.0,
              right: 16.0,
              bottom: 10,
            ),
            child: const Text(
              'Ya se han cargado los contactos, pulse el '
              'siguiente botón para reiniciar la aplicación',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          ElevatedButton(
            onPressed: () {
              Restart.restartApp(webOrigin: 'loginRegister');
            },
            style: const ButtonStyle(
              minimumSize: MaterialStatePropertyAll(
                Size(220, 40)
              )
            ),
            child: const Text(
              'Reiniciar',
              style: TextStyle(
                fontSize: 20
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget que se utiliza cuando aún no se han solicitado
// los permisos. Consiste en un botón con un evento asociado 
// de solicitud de permisos
class LoadContactsButton extends StatelessWidget {
  
  final VoidCallback onPressed;

  const LoadContactsButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 10.0,
            right: 10.0,
            bottom: 20.0
          ),
          child: const Text(
            'Pulse el siguiente botón para poder cargar los contactos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onPressed,
          style: const ButtonStyle(
            minimumSize: MaterialStatePropertyAll(
              Size(220, 40)
            )
          ),
          child: const Text(
            'Cargar Contactos',
            style: TextStyle(
              fontSize: 20
            ),
          ),
        ),
      ],
    ),
  );
}

// Widget muy similar al anterior, se usa en caso de
// que se hayan denegado los permisos una o dos veces.
// Muestra un mensaje de por qué la aplicación necesita 
// los permisos
class AskPermissionsButton extends StatelessWidget {

  final bool isPermanent;
  final VoidCallback onPressed;
    
  const AskPermissionsButton({
    Key? key,
    required this.isPermanent,
    required this.onPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 24.0,
              right: 16.0,
            ),
            child: const Text(
              'Permisos de Contactos',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold
                ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 24.0,
              right: 16.0,
            ),
            child: const Text(
              'La aplicación necesita los permisos sobre '
                  'los contactos para funcionar correctamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20
              ),
            ),
          ),
          // Si es la segunda vez que se deniegan los permisos
          // aparecerá este Container
          if (isPermanent)
            Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 24.0,
                right: 16.0,
              ),
              child: const Text(
                'Necesitas dar los permisos desde los ajustes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.only(
                left: 16.0, top: 24.0, right: 16.0, bottom: 24.0),
            child: ElevatedButton(
              // En función de si es la primera o segunda que se deniegan los permisos,
              // aparecerá un mensaje u otro en el botón, así como el evento asociado
              // será diferente
              style: const ButtonStyle(
                minimumSize: MaterialStatePropertyAll(
                  Size(220, 40)
                )
              ),
              onPressed: () => isPermanent ? openAppSettings() : onPressed(),
              // En función de si es la primera o segunda que se deniegan los permisos,
              // aparecerá un mensaje u otro en el botón, así como el evento asociado
              // será diferente
              child: Text(
                isPermanent ? 'Abrir Ajustes' : 'Cargar Contactos',
                style: const TextStyle(
                  fontSize: 20
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget que se utiliza para mostrar 
// los contactos del usuario por pantalla
class ContactsLoaded extends StatelessWidget {
  final List<MyContact> contacts;

  const ContactsLoaded({
    super.key, 
    required this.contacts,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        if (contacts.isNotEmpty)
          Expanded(
            // El ListView.builder generará, en este caso,
            // un Card por cada elemento que contenga
            // la lista que se le pasa (contacts)
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (BuildContext context, int index) {
                final contact = contacts[index];
                // El GestureDetector permite que podamos
                // pulsar en cualquier parte del Card 
                // (un Card en este caso)
                return ContactCard(
                  contact: contact
                );
              },
            ),
          )
        else
          const ErrorScreen(
            errorCode: 3
          ),
      ],
    );
  }
}

// Widget que servirá como cuerpo del 
// ListView.builder
class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.contact,
  });

  final MyContact contact;

  @override
  Widget build(BuildContext context) {
    String profilePic = userProfilePic();

    return GestureDetector(
      onTap: () {
        // Al pulsar nos vamos a la pantalla
        // en concreto de cada contacto
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContactScreen(
              contact: contact,
              userProfilePic: profilePic,
            )
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 250,
        margin: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ClipRRect(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(20),
              child: FadeInImage(
                placeholder: const AssetImage('assets/user_profile_pic.png'), 
                image: AssetImage(profilePic),
                width: 250,
                height: 250,
                fit: BoxFit.cover,
              )
            ),
            Container(
              padding: const EdgeInsets.only(top: 3, left: 3),
              width: 250,
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 129, 163, 180),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 3), // Posición del sombreado
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    contact.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 19
                    ),
                  ),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Método para crear un objeto de tipo MyContact
MyContact createMyContact(ContactFormProvider contactFormProvider, String nombre, String telefono, String deviceNumber) { 
  MyContact contact = MyContact(
    numUsuario: deviceNumber, 
    nombre: nombre, 
    telefono: telefono,
    borrado: 0,
  );

  return contact;
}

// Método que se usa cuando se accede a la aplicación 
// desde el registro.
// Compara los contactos del dispositivo con los
// existentes en BBDD asociados al dispositivo
// y los añade a una lista
List<MyContact> creatMyContactsList(List<Contact> contacts, ContactFormProvider contactFormProvider, String deviceNumber, String updatedContacts){
  List<MyContact> myContactsList = [];

  if(updatedContacts.isEmpty) {
    for (var i = 0; i < contacts.length; i++) {
      bool contactExists = false;

      for (var j = 0; j < contactFormProvider.contactServices.contacts.length; j++) {
        if (contacts[i].phones![0].value! == contactFormProvider.contactServices.contacts[j].telefono &&
            deviceNumber == contactFormProvider.contactServices.contacts[j].numUsuario) {
          contactExists = true;
          break;
        }
      }

      if (!contactExists) {
        myContactsList.add(createMyContact(contactFormProvider, contacts[i].displayName!, contacts[i].phones![0].value!, deviceNumber));
      }
    }
  }

  UpdatedContacts.setUpdatedContacts('Se han sudido los contactos');
  return myContactsList;
}

// Método que recorre una lista de tipo 
// MyContact y los sube a BBDD
void uploadContacts(List<MyContact> myContactsList, ContactFormProvider contactsProvider){
  // En caso de haberlos, eliminamos los elementos duplicados
  myContactsList = myContactsList.toSet().toList();

  // Recorremos la lista y subimos el contacto de la iteración
  for (var i = 0; i < myContactsList.length; i++) {
    contactsProvider.contactServices.createContact(myContactsList[i]);
  }
}

// Método para filtrar los contactos de BBDD
// devolviendo una lista con los contactos
// asociados al dispositivo
List<MyContact> filterContacts(ContactFormProvider contactFormProvider, String deviceNumber ) {
  List<MyContact> filteredContacts = [];

  for (var i = 0; i < contactFormProvider.contactServices.contacts.length; i++) {
    if(contactFormProvider.contactServices.contacts[i].numUsuario == deviceNumber &&
        contactFormProvider.contactServices.contacts[i].borrado == 0
    ) {
      filteredContacts.add(contactFormProvider.contactServices.contacts[i]);
    }
  }
  
  // Ordenamos los contactos por orden alfabético
  filteredContacts.sort((a, b) => a.nombre.compareTo(b.nombre));
  // En caso de haberlos, eliminamos los elementos duplicados
  filteredContacts = filteredContacts.toSet().toList();

  return filteredContacts;
}

String userProfilePic(){
  final random = Random();
  int numberOfPhotos = 4;
  String name = 'assets/user_profile_picture';

  final randomIndex = random.nextInt(numberOfPhotos) + 1;
  name += '_$randomIndex.png';

  return name;
}