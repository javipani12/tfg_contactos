import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/screens/screens.dart';
import 'package:tfg_contactos/services/services.dart';
import 'package:tfg_contactos/widgets/widgets.dart';
import 'package:tfg_contactos/models/models.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key,}) : super(key: key);
  
  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> with WidgetsBindingObserver{
  late final ContactPermissions _permissions;
  late final SharedPreferences prefs;
  String deviceNumber = GlobalVariables.user.telefono;
  List<Contact> deviceContacts = [];
  bool hasPermission = false;
  bool _detectPermission = false;
  

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
    Widget add = Container();
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
            WidgetsBinding.instance.addPostFrameCallback((_) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  contactsProvider.notifyChanges();
                });
            });
            GlobalVariables.filteredContacts = filterContacts(contactsProvider, deviceNumber);
            add = addAndProfileWidgets(context, 0, usersProvider, contactsProvider, deviceNumber, GlobalVariables.filteredContacts);
            profile = addAndProfileWidgets(context, 1, usersProvider, contactsProvider, deviceNumber, GlobalVariables.filteredContacts);
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
                uploadContacts(deviceContacts, contactsProvider, deviceNumber);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      contactsProvider.notifyChanges();
                    });
                });
                GlobalVariables.filteredContacts = filterContacts(contactsProvider, deviceNumber);
                add = addAndProfileWidgets(context, 0, usersProvider, contactsProvider, deviceNumber, GlobalVariables.filteredContacts);
                profile = addAndProfileWidgets(context, 1, usersProvider, contactsProvider, deviceNumber, GlobalVariables.filteredContacts);
                widget = ContactsLoaded(contacts: GlobalVariables.filteredContacts);
                break;
            }
          }
          
          return Scaffold(
            appBar: AppBar(
              title: const Text('Contactos'),
              automaticallyImplyLeading: false,
              actions: [
                profile,
                add
              ],
            ),
            body: widget,
          );
        },
      )
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
    child: ElevatedButton(
      onPressed: onPressed,
      child: const Text('Cargar Contactos'),
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
            child: Text(
              'Permisos de Contactos',
              style: Theme.of(context).textTheme.headline6,
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
              ),
            ),
          Container(
            padding: const EdgeInsets.only(
                left: 16.0, top: 24.0, right: 16.0, bottom: 24.0),
            child: ElevatedButton(
              // En función de si es la primera o segunda que se deniegan los permisos,
              // aparecerá un mensaje u otro en el botón, así como el evento asociado
              // será diferente
              child: Text(isPermanent ? 'Abrir Ajustes' : 'Cargar Contactos'),
              onPressed: () => isPermanent ? openAppSettings() : onPressed(),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactsLoaded extends StatelessWidget {
  final List<MyContact> contacts;

  const ContactsLoaded({
    required this.contacts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (contacts.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (BuildContext context, int index) {
                final contact = contacts[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.amber,
                  child: Column(
                    children: [
                      Text(contact.nombre),
                      Text(contact.telefono),
                    ],
                  ),
                );
              },
            ),
          )
        else
          const Expanded(
            child: SizedBox(
              height: double.infinity / 2,
              child: Center(
                child: CircularProgressIndicator()
                ),
            ),
          ),
      ],
    );
  }
}


// Método para crear un objeto de tipo MyContact
// y subirlo a BBDD
void uploadContact(ContactFormProvider contactFormProvider, String nombre, String telefono, String deviceNumber) { 
  MyContact contact = MyContact(
    numUsuario: deviceNumber, 
    nombre: nombre, 
    telefono: telefono,
    borrado: 0,
  );
  contactFormProvider.contactServices.createContact(contact);
}

// Método que se usa cuando se accede a la aplicación 
// desde el registro
// Compara los contactos del dispositivo con los
// existentes en BBDD asociados al dispositivo
// Si hay algún que no existe en BBDD lo sube
void uploadContacts(List<Contact> contacts, ContactFormProvider contactFormProvider, String deviceNumber){

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
      uploadContact(contactFormProvider, contacts[i].displayName!, contacts[i].phones![0].value!, deviceNumber);
    }
  }

  //
}

// Método para filtrar los contactos de BBDD
// devolviendo una lista con los contactos
// asociados al dispositivo
List<MyContact> filterContacts(ContactFormProvider contactFormProvider, String deviceNumber) {
  List<MyContact> filteredContacts = [];

  for (var i = 0; i < contactFormProvider.contactServices.contacts.length; i++) {
    if(contactFormProvider.contactServices.contacts[i].numUsuario == deviceNumber &&
        contactFormProvider.contactServices.contacts[i].borrado == 0
    ) {
      filteredContacts.add(contactFormProvider.contactServices.contacts[i]);
    }
  }

  // Ordenamos los contactos por orden alfabético
  filteredContacts.sort((a, b) => a.nombre.compareTo(b.nombre),);

  return filteredContacts;
}

// Método para rellenar los Widgets que irán 
// en el AppBar
Widget addAndProfileWidgets(
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
  }

  return widget;   
}