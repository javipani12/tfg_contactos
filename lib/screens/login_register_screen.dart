import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'dart:math';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/screens/screens.dart';
import 'package:tfg_contactos/themes/app_themes.dart';
import 'package:provider/provider.dart';
import 'package:tfg_contactos/widgets/widgets.dart';

class LoginRegisterScreen extends StatelessWidget {
  const LoginRegisterScreen({
    Key? key,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {

    UserLoginRegisterFormProvider usersProvider = Provider.of<UserLoginRegisterFormProvider>(context);

    return FutureBuilder<String>(
      // Llamada al método asíncrono
      future: DeviceNumber.getNumber(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Valor obtenido del Future
          String deviceNumber = snapshot.data!;
          Widget widget;

          // En función del valor, mostramos una ventana u otra
          if(deviceNumber.isNotEmpty) {
            widget = Login(
              usersProvider: usersProvider,
              deviceNumber: deviceNumber,  
            );
          } else {
            widget = Register(
              usersProvider: usersProvider,
            );
          }
      
          return widget;
        } else if (snapshot.hasError) {
          // Manejar el error en caso de que ocurra
          return const ErrorScreen(
            errorCode: 1
          );
        } else {
          // Muestra un indicador de carga mientras se espera la respuesta
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class Login extends StatelessWidget {
  const Login({
    Key? key,
    required this.usersProvider,
    required this.deviceNumber,
  }) : super(key: key);

  final UserLoginRegisterFormProvider usersProvider;
  final String deviceNumber;

  @override
  Widget build(BuildContext context) {
    bool isValid = usersProvider.isValidLogin(deviceNumber);

    if (isValid) {
      GlobalVariables.user = usersProvider.getUser(deviceNumber);
      // Si el número de dispositivo es válido, redirige a la pantalla ContactScreen
      return const ContactsScreen();
    } else {
      // Si el número de dispositivo no es válido, muestra un mensaje de error en pantalla
      return const ErrorScreen(
        errorCode: 2
      );
    }
  }
}


class Register extends StatelessWidget {
  const Register({
    Key? key,
    required this.usersProvider,
  }) : super(key: key);

  final UserLoginRegisterFormProvider usersProvider;

  @override
  Widget build(BuildContext context) {

    String phoneNumber = '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos'),
      ),
      body: Form(
        key: usersProvider.formKey,
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                phoneNumber = value;
              },
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
                if (usersProvider.isValidForm()) {
                  final isValidPhoneNumber = usersProvider.isValidRegister(phoneNumber);
                  switch (isValidPhoneNumber) {
                    case 0:
                      await DeviceNumber.setNumber(phoneNumber);
                      String pass = generateRandomString();
                      await DevicePass.setPass(pass);
                      User user = User(
                        clave: pass, 
                        telefono: phoneNumber,
                      );
                      GlobalVariables.user = user;
                      usersProvider.usersServices.createUser(user);
                      // Navegar a la pantalla ContactScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactsScreen()
                        ),
                      );
                      break;
                    case 1:
                      PopUp.duplicatedMessage(context, 0).then((_) async {
                        User user = usersProvider.getUser(phoneNumber);
                        await DeviceNumber.setNumber(user.telefono);
                        await DevicePass.setPass(user.clave);
                        GlobalVariables.user = user;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactsScreen()
                          ),
                        );
                      });
                      break;
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
}

// Pantalla creada para mostrar el error ocurrido
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    Key? key,
    required this.errorCode,
  }) : super(key: key);

  final int errorCode;

  @override
  Widget build(BuildContext context) {

    // Posibles códigos de errores:
    // 1: El dato persistente de la aplicación no se ha cargado bien
    // 2: El dato persistente almacenado en la aplicación 
    //    no coincide con ninguno en Firebase

    String errorMessage = '';

    switch(errorCode) {
      case 1:
        errorMessage = 'Se ha producido un error al cargar '
                        'el número de teléfono del dispositivo';
        break;
      case 2:
        errorMessage = 'El número de teléfono del dispositivo '
                        'no coincide con los existentes';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos'),
      ),
      body: Center(
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
                'Se ha producido un error',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 24.0,
                right: 16.0,
              ),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
              ),
            ),
          ]
        )
      )
    );
  }
}

String generateRandomString() {
  final random = Random();
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  String randomString = '';

  for (int i = 0; i < 5; i++) {
    final randomIndex = random.nextInt(characters.length);
    randomString += characters[randomIndex];
  }

  return randomString;
}
