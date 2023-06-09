import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'dart:math';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/screens/screens.dart';
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
          // Almacenamos el valor obtenido del Future
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
          // Manejamos el error en caso de que este ocurra
          return const ErrorScreen(
            errorCode: 1
          );
        } else {
          // Mostramos un indicador de carga mientras se espera la respuesta
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

// Login automático de la aplicación
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

    // Comprobamos si el número del dispositivo es válido
    if (isValid) {
      // Si el número de dispositivo es válido, 
      // almacenamos el usuario en las variables
      // globales y redirigimos a ContactsScreen
      GlobalVariables.user = usersProvider.getUser(deviceNumber);
      return const ContactsScreen();
    } else {
      // Si el número de dispositivo no es válido, 
      // mostramos un mensaje de error en pantalla
      return const ErrorScreen(
        errorCode: 2
      );
    }
  }
}

// Panta de Registro
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
      // Formulario de registro
      body: Form(
        key: usersProvider.formKey,
        child: Column(
          children: [
            const SizedBox(
              height: 80,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 30
              ),
              child: const Text(
                'Bienvenido/a a la aplicación de contactos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 10.0,
                top: 30.0,
                right: 10.0,
                bottom: 10.0
              ),
              child: const Text(
                'Introduzca su número de teléfono '
                    'poder continuar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal
                ),
              ),
            ),
            // Campo para el teléfono
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
              child: TextFormField(
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
            ),
            // Botón para continuar
            ElevatedButton(
              onPressed: () async {
                // Comprobamos si el formulario es válido
                if (usersProvider.isValidForm()) {
                  // Comprobamos si el número existe o no en BBDD
                  final isValidPhoneNumber = usersProvider.isValidRegister(phoneNumber);
                  switch (isValidPhoneNumber) {
                    // Si no existe, establecemos los diferentes 
                    // valores persistentes y variables globales
                    // y creamos y subimos el usuario
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
                    // Si existe, obtenemos dicho usuario 
                    // y establecemos los diferentes 
                    // valores persistentes y variables globales
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

// Método para generar una clave Random de 5 carácteres
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
