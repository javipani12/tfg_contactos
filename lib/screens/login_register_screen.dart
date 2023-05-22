import 'package:flutter/material.dart';
import 'package:tfg_contactos/models/models.dart';
import 'dart:math';
import 'package:tfg_contactos/providers/providers.dart';
import 'package:tfg_contactos/screens/screens.dart';
import 'package:tfg_contactos/themes/app_themes.dart';
import 'package:provider/provider.dart';
import 'package:tfg_contactos/widgets/widgets.dart';

class LoginRegisterScreen extends StatelessWidget {
  const LoginRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) {
        return UserLoginRegisterFormProvider();
      },
      child: const _LoginRegisterBody(),
    );
  }
}

class _LoginRegisterBody extends StatelessWidget {
  const _LoginRegisterBody({
    Key? key,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {

    final usersProvider = Provider.of<UserLoginRegisterFormProvider>(context);

    return FutureBuilder<String>(
      // Llamada al método asíncrono
      future: DeviceNumber.getNumber(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Valor obtenido del Future
          String deviceNumber = snapshot.data!;
          Widget widget;
      
          if(deviceNumber.isNotEmpty) {
            widget = Login(
              loginRegisterForm: usersProvider,
              deviceNumber: deviceNumber,  
            );
          } else {
            widget = Register(
              loginRegisterForm: usersProvider,
            );
          }
      
          return widget;
        } else if (snapshot.hasError) {
          // Manejar el error en caso de que ocurra
          return Container();
        } else {
          // Muestra un indicador de carga mientras se espera la respuesta
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class Login extends StatelessWidget {
  const Login({
    Key? key,
    required this.loginRegisterForm,
    required this.deviceNumber,
  }) : super(key: key);

  final UserLoginRegisterFormProvider loginRegisterForm;
  final String deviceNumber;

  @override
  Widget build(BuildContext context) {
    bool isValid = loginRegisterForm.isValidLogin(deviceNumber);

    if (isValid) {
      // Si el número de dispositivo es válido, redirige a la pantalla ContactScreen
      return ContactScreen();
    } else {
      // Si el número de dispositivo no es válido, muestra un mensaje de error en pantalla
      return Scaffold(
        body: Center(
          child: Text(
            'Error: El número de dispositivo no es válido',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
  }
}


class Register extends StatelessWidget {
  const Register({
    Key? key,
    required this.loginRegisterForm,
  }) : super(key: key);

  final UserLoginRegisterFormProvider loginRegisterForm;

  @override
  Widget build(BuildContext context) {

    String phoneNumber = '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos'),
      ),
      body: Form(
        key: loginRegisterForm.formKey,
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                phoneNumber = value;
              },
              decoration: InputDecoration(hintText: 'Teléfono'),
              validator: (value) {
                if (value!.length != 9) {
                  return 'La longitud debe ser 9';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () async {
                if (loginRegisterForm.formKey.currentState?.validate() == true) {
                  final isValidPhoneNumber = loginRegisterForm.isValidRegister(phoneNumber);
                  switch (isValidPhoneNumber) {
                    case 0:
                      await DeviceNumber.setNumber(phoneNumber);
                      String pass = generateRandomString();
                      await DevicePass.setPass(pass);
                      User user = User(
                        clave: pass, 
                        telefono: phoneNumber,
                      );
                      loginRegisterForm.usersServices.createUser(user);
                      // Navegar a la pantalla ContactScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ContactScreen()),
                      );
                      break;
                    case 1:
                      User user = loginRegisterForm.getUser(phoneNumber);
                      await DeviceNumber.setNumber(user.telefono);
                      await DevicePass.setPass(user.clave);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ContactScreen()),
                      );
                    break;
                    default:
                      // Mostrar mensaje de error
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Error'),
                          content: Text('El número de teléfono ya existe en la base de datos.'),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cerrar'),
                            ),
                          ],
                        ),
                      );
                    break;
                  }
                }
              },
              child: Text('Registrarse'),
            ),
          ],
        ),
      ),
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
