import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color primaryColor = Colors.blue;
const Color backgroundColor = Color.fromRGBO(0, 11, 22, 1.0);

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<bool> reauthenticateUser(BuildContext context, String password) async {
    User? user = FirebaseAuth.instance.currentUser;
    bool reauthenticated = false;

    if (user != null && user.email != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      try {
        await user.reauthenticateWithCredential(credential);
        reauthenticated = true; // Reautenticación exitosa
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de reautenticación: ${e.message}')),
        );
      }
    }

    return reauthenticated;
  }

  Future<void> updateEmail(
      BuildContext context, String newEmail, String currentPassword) async {
    bool reauthenticated = await reauthenticateUser(context, currentPassword);

    if (!reauthenticated) {
      return; // Detener si la reautenticación falla
    }

    try {
      await user?.updateEmail(newEmail);
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user?.uid)
          .update({
        'correo': newEmail,
      });
      Navigator.of(context).pop(); // Cierra el diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Correo electrónico actualizado con éxito')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Cierra el diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el correo electrónico')),
      );
    }
  }

  void showEditEmailDialog(BuildContext context) {
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Actualizar correo electrónico'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration:
                    InputDecoration(hintText: 'Nuevo correo electrónico'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(hintText: 'Contraseña actual'),
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Actualizar'),
              onPressed: () {
                updateEmail(
                    context, _emailController.text, _passwordController.text);
                Navigator.of(context).pop(); // Considera cerrar el diálogo aquí
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateName(BuildContext context, String newName) async {
    try {
      await user?.updateProfile(displayName: newName);
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user?.uid)
          .update({
        'nombre': newName,
      });
      Navigator.of(context).pop(); // Cierra el diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nombre actualizado con éxito')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Cierra el diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el nombre')),
      );
    }
  }

  Future<void> deleteUser(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user?.uid)
          .delete();
      await user?.delete();
      Navigator.of(context).pop(); // Cierra el diálogo
      // Aquí podrías redirigir al usuario a la pantalla de inicio de sesión o similar
    } catch (e) {
      Navigator.of(context).pop(); // Cierra el diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la cuenta')),
      );
    }
  }

  void showEditDialog(BuildContext context, String title, String hint,
      Function(String) onSubmit) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hint),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () => onSubmit(controller.text),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Configuración', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Actualizar Correo',
                style: TextStyle(color: Colors.white)),
            leading: Icon(Icons.email, color: Colors.white),
            onTap: () => showEditEmailDialog(context),
          ),
          Divider(color: Colors.blueGrey[900]),
          ListTile(
            title: Text('Actualizar Nombre',
                style: TextStyle(color: Colors.white)),
            leading: Icon(Icons.person, color: Colors.white),
            onTap: () => showEditDialog(
              context,
              'Actualizar nombre',
              'Ingresa tu nuevo nombre',
              (newName) => updateName(context, newName),
            ),
          ),
          Divider(color: Colors.blueGrey[900]),
          ListTile(
            title:
                Text('Eliminar Cuenta', style: TextStyle(color: Colors.white)),
            leading: Icon(Icons.delete_forever, color: Colors.white),
            onTap: () {
              // Aquí puedes decidir si mostrar un diálogo de confirmación antes de llamar a deleteUser
              deleteUser(context);
            },
          ),
          Divider(color: Colors.blueGrey[900]),
        ],
      ),
    );
  }
}
