import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg_contactos/models/models.dart';

class ContactScreen extends StatefulWidget {
   
  const ContactScreen({Key? key}) : super(key: key);
  
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> with WidgetsBindingObserver{

  late final ContactPermissions _permissions;
  late final SharedPreferences prefs;
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _permissions,
      child: Consumer<ContactPermissions>(
        builder: (context, value, child) {
          Widget widget;

          if(hasPermission) {
            widget = ContactLoaded(permissions: _permissions,);
          } else {
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
                widget = ContactLoaded(permissions: _permissions,);
                break;
            }
          }
          
          return Scaffold(
            appBar: AppBar(
              title: const Text('Contactos'),
            ),
            body: widget,
          );
        },
      )
    );
  }

  Future<void> _checkPermissions() async {
    final hasContactPermission = await _permissions.requestContactPermission();
    if(hasContactPermission) {
      try {
        await _permissions.storeContacts();
      } on Exception catch (e) {
        debugPrint('Error al cargar los contactos: $e');
      }
    }
  }

  Future<void> initializeHasPermissions() async {
    hasPermission = await _permissions.initializeHasPermissions();
  }
}


class LoadContactsButton extends StatelessWidget {
  
  final VoidCallback onPressed;

  const LoadContactsButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) => Center(
    child: ElevatedButton(
      child: const Text('Cargar Contactos'),
      onPressed: onPressed,
    ),
  );
}


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
              child: Text(isPermanent ? 'Abrir Ajustes' : 'Cargar Contactos'),
              onPressed: () => isPermanent ? openAppSettings() : onPressed(),
            ),
          ),
        ],
      ),
    );
  }
}


class ContactsLoading extends StatelessWidget {
   
  const ContactsLoading({
    Key? key
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.indigo,
      ),
    );
  }
}


class ContactLoaded extends StatelessWidget {

  final ContactPermissions permissions;
   
  const ContactLoaded({
    Key? key,
    required this.permissions
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    if (permissions.isLoading) {
      return const ContactsLoading();
    } else {
      return Column(
        children: [ 
          Expanded(
            child: ListView.builder(
              itemCount: permissions.contacts.length,
              itemBuilder: (BuildContext context, int index) {
                final contact = permissions.contacts[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.amber,
                  child: Column(
                    children: [
                      Text(contact.displayName ?? ''),
                      Text(contact.phones![0].value ?? ''),
                    ],
                  ),
                );
              }
            )
          )
        ],
      );
    }
  }
}