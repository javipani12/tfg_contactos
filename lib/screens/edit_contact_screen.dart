import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/screens/screens.dart';
import 'package:tfg_contactos/themes/app_themes.dart';
import 'package:tfg_contactos/widgets/widgets.dart';

class EditContactScreen extends StatefulWidget {

  final MyContact contact;
  final ContactFormProvider contactsProvider;

  const EditContactScreen({
    super.key, 
    required this.contact,
    required this.contactsProvider
  });

  @override
  State<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController nombreController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nombreController.text = widget.contact.nombre;
    telefonoController.text = widget.contact.telefono;
  }

  @override
  void dispose() {
    nombreController.dispose();
    telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Contacto'),
      ),
      // Formulario de edición del contacto
      body: Form(
        key: formKey,
        child: Column(
          children: [
            // Campo para el nombre
            TextFormField(
              controller: nombreController,
              decoration: const InputDecoration(hintText: 'Nombre'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'El nombre no puede estar vacío';
                }
                return null;
              },
            ),
            // Campo para el teléfono
            TextFormField(
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
            // Botón para actualizar el contacto 
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  // Si el valor del teléfono no ha cambiado,
                  // mensaje de todo bienactualizamos
                  if(telefonoController.text == widget.contact.telefono){
                    updateEditedContact(context);
                  } else {
                    // Si ha cambiado comprobamos que no exista en BBDD
                    int updateContactState = widget.contactsProvider.isValidContact(
                      GlobalVariables.user.telefono, 
                      telefonoController.text
                    );

                    // Si existe, mensaje de error
                    if ( updateContactState == 1 ) {
                      PopUp.duplicatedMessage(context, 2);
                    } else {
                      // En caso contrario mensaje de todo bien
                      // y actualizamos
                      updateEditedContact(context);
                    }
                  }
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  // Método local para actualizar el contacto, 
  // estableciendo los nuevos valores tanto a dicho
  // contacto como a los datos persistentes y a
  // las variables globales.
  void updateEditedContact(BuildContext context) {
    PopUp.okMessage(context, 1).then((_) async {
      widget.contact.nombre = nombreController.text;
      widget.contact.telefono = telefonoController.text;
      widget.contactsProvider.contactServices.updateContact(widget.contact);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactScreen(
            contact: widget.contact
          )
        ),
      );
    });
  }
}