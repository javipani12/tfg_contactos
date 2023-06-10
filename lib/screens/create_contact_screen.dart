import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/screens/screens.dart';
import 'package:tfg_contactos/widgets/widgets.dart';

class CreateContactScreen extends StatefulWidget {
  const CreateContactScreen({Key? key,
    required this.contactsProvider,
    required this.filteredContacts,
  }) : super(key: key);

  final ContactFormProvider contactsProvider;
  final List<MyContact> filteredContacts;

  @override
  State<CreateContactScreen> createState() => _CreateContactScreenState();
}

class _CreateContactScreenState extends State<CreateContactScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
          widget.contactsProvider, 
          GlobalVariables.user.telefono, 
          GlobalVariables.filteredContacts,
          contact,
          ''
        ),
      ),
      // Formulario para la creación de un contacto
      body: Form(
        key: formKey,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 10.0,
                top: 30.0,
                right: 10.0,
                bottom: 10.0
              ),
              child: const Text(
                'Introduzca en los siguientes campos el Nombre '
                'y el Teléfono del contacto a crear',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            // Campo del nombre
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 20,
              ),
              child: TextFormField(
                onChanged: (value) {
                  nombre = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Nombre'
                ),
                style: const TextStyle(
                  fontSize: 20
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  return null;
                },
              ),
            ),
            // Campo del teléfono
            Container(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: TextFormField(
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  telefono = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Teléfono'
                ),
                style: const TextStyle(
                  fontSize: 20
                ),
                validator: (value) {
                  if (value!.length != 9) {
                    return 'La longitud debe ser 9';
                  }
                  return null;
                },
              ),
            ),
            // Botón para la creación del contacto
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  int createContactState = comparePhoneNumber(widget.filteredContacts, telefono);
                  // Si ya existe el teléfono, mensaje de error
                  if ( createContactState == 1) {
                    PopUp.duplicatedMessage(context, 1);
                  } else {
                    // En caso contrario, mensaje de todo correcto
                    createNewContact(context, contact, nombre, telefono);
                  }
                }
              },
              style: const ButtonStyle(
                minimumSize: MaterialStatePropertyAll(
                  Size(220, 40)
                )
              ),
              child: const Text(
                'Crear',
                style: TextStyle(
                  fontSize: 20
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método local para crear un nuevo contacto, 
  // estableciendo los nuevos valores a los 
  // datos persistentes y a las variables globales.
  void createNewContact(BuildContext context, MyContact contact, String nombre, String telefono) {
    PopUp.okMessage(context, 0).then((_) async {
      contact.nombre = nombre;
      contact.telefono = telefono;
      await widget.contactsProvider.contactServices.createContact(contact);
      widget.contactsProvider.notifyChanges();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ContactsScreen()
        ),
      );
    });
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