import 'package:flutter/material.dart';

class CreateContactScreen extends StatelessWidget {
  const CreateContactScreen({super.key});

  @override
  Widget build(BuildContext context) {

    

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Contacto'),
      ),
      body: Center(
        child: Text('Contact Screen'),
      ),
    );
  }
}