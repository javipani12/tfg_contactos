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
      body: Form(
        key: formKey,
        child: Column(
          children: [
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
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  if(telefonoController.text == widget.contact.telefono){
                    updateEditedContact(context);
                  } else {
                    int updateContactState = widget.contactsProvider.isValidContact(
                      GlobalVariables.user.telefono, 
                      telefonoController.text
                    );

                    if ( updateContactState == 1 ) {
                      PopUp.duplicatedMessage(context, 2);
                    } else {
                      updateEditedContact(context);
                    }
                  }
                }
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }

  void updateEditedContact(BuildContext context) {
    PopUp.okMessage(context, 1).then((_) async {
      widget.contact.nombre = nombreController.text;
      widget.contact.telefono = telefonoController.text;
      widget.contactsProvider.contactServices.updateContact(widget.contact);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactsScreen()
        ),
      );
    });
  }
}