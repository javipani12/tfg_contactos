import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/screens/screens.dart';
import 'package:tfg_contactos/widgets/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    Key? key,
    required this.usersProvider,
    required this.contactsProvider,
    required this.user,
  }) : super(key: key);

  final UserLoginRegisterFormProvider usersProvider;
  final ContactFormProvider contactsProvider;
  final User user;

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController telefonoController = TextEditingController();
  TextEditingController claveController = TextEditingController();

  @override
  void initState() {
    super.initState();
    telefonoController.text = widget.user.telefono;
    claveController.text = widget.user.clave;
  }

  @override
  void dispose() {
    telefonoController.dispose();
    claveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      // Formulario de edición
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
                'Modifica el Teléfono o la Clave de tu perfil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            // Campo para el teléfono
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 20,
              ),
              child: TextFormField(
                controller: telefonoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: 'Teléfono'),
                validator: (value) {
                  if (value!.length != 9) {
                    return 'La longitud debe ser 9';
                  }
                  return null;
                },
              ),
            ),
            // Campo para la clave
            Container(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: TextFormField(
                controller: claveController,
                decoration: const InputDecoration(hintText: 'Clave'),
                validator: (value) {
                  if (value!.length != 5) {
                    return 'La longitud debe ser 5';
                  }
                  return null;
                },
              ),
            ),
            // Botón para actualizar
            ElevatedButton(
              onPressed: () async {
                if(formKey.currentState?.validate() ?? false) {
                  if(telefonoController.text == GlobalVariables.user.telefono) {
                    await updateEditedUser(context);
                  } else {
                    int updateUserState = widget.usersProvider.isValidRegister(telefonoController.text);
                    if (updateUserState == 1) {
                      PopUp.duplicatedMessage(context, 1);
                    } else {
                      await updateEditedUser(context);
                    }
                  }
                }
              },
              style: const ButtonStyle(
                minimumSize: MaterialStatePropertyAll(
                  Size(220, 40)
                )
              ),
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  // Método local para actualizar el usuario actual, 
  // estableciendo los nuevos valores tanto a dicho
  // usuario como a los datos persistentes y a
  // las variables globales.
  Future<void> updateEditedUser(BuildContext context) async {
    PopUp.okMessage(context, 2).then((_) async {
      widget.user.telefono = telefonoController.text;
      widget.user.clave = claveController.text;
      await DeviceNumber.setNumber(widget.user.telefono);
      await DevicePass.setPass(widget.user.clave);
      GlobalVariables.user = widget.user;
      await widget.usersProvider.usersServices.updateUser(widget.user);
      updateContacNumUser(widget.contactsProvider);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            usersProvider: widget.usersProvider,
            deviceNumber: widget.user.telefono,
          ),
        ),
      );
    });
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