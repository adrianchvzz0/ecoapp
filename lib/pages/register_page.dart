// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmpasswordController = TextEditingController();

  void guardarDatosUsuario(String uid, String nombre, String correo) async {
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nombre': nombre,
        'correo': correo,
      });
      print('Datos del usuario guardados correctamente');
    } catch (e) {
      print('Error al guardar los datos del usuario: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }

  Future signUp() async {
    // Verifica si los campos son válidos
    if (!fieldsAreValid()) return;

    if (!passwordConfirmed()) {
      showErrorDialog("Las contraseñas no coinciden.");
      return;
    }
    try {
      // Intenta crear un nuevo usuario con email y contraseña
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Obtiene el UID del usuario
      String uid = userCredential.user!.uid;
      // Obtiene el email del usuario (opcional, ya que lo tienes en _emailController)
      String email = userCredential.user!.email!;

      // Aquí guardas el nombre y el correo en Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nombre': _nameController.text
            .trim(), // Asegúrate de que el campo sea 'nombre'
        'correo':
            email, // Utiliza el correo del controlador o el del usuario autenticado
      });

      // Aquí continúa tu lógica de éxito...
    } catch (e) {
      if (e is FirebaseAuthException) {
        handleAuthError(e);
      } else {
        // Si capturas otro tipo de error que no sea FirebaseAuthException,
        // puedes manejarlo de otra manera o simplemente mostrar un mensaje genérico.
        showErrorDialog(
            "Ocurrió un error desconocido. Por favor, intenta nuevamente.");
      }
    }
  }

  bool fieldsAreValid() {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty ||
        _confirmpasswordController.text.trim().isEmpty) {
      showErrorDialog("Por favor, llena todos los campos para continuar.");
      return false;
    }
    if (!emailIsValid(_emailController.text.trim())) {
      showErrorDialog(
          "Asegúrate de usar un correo real, por ejemplo: nombre@tucorreo.com");
      return false;
    }
    return true;
  }

  bool emailIsValid(String email) {
    // Expresión regular para validar un correo electrónico
    final emailRegex = RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    return emailRegex.hasMatch(email);
  }

  bool passwordConfirmed() {
    return _passwordController.text.trim() ==
        _confirmpasswordController.text.trim();
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Error", style: TextStyle(color: Colors.white)),
          content: Text(message, style: TextStyle(color: Colors.grey[200])),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          backgroundColor: Colors.blueGrey[900],
        );
      },
    );
  }

  void handleAuthError(FirebaseAuthException e) {
    String errorMessage = "Ocurrió un error. Por favor, intenta nuevamente.";
    switch (e.code) {
      case "email-already-in-use":
        errorMessage = "Ya existe un usuario con este correo";
        break;
      case "weak-password":
        errorMessage = "La contraseña es demasiado débil.";
        break;
      // Aquí puedes manejar otros códigos de error específicos...
    }
    showErrorDialog(errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(00, 11, 22, 1.0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Hello Again
                SizedBox(
                  height: 20,
                  width: 300,
                ),
                Text(
                  'ecoinnova.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 0),
                Text(
                  's o l u t i o n s',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),

                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50.0), // Ajusta según necesites
                    child: Text(
                      'Crea una cuenta!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Name textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0,
                          right:
                              20.0), // Ajuste agregado para el padding derecho
                      child: TextField(
                        controller: _nameController,
                        textAlign: TextAlign
                            .left, // Esta es la línea clave para centrar el texto
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Nombre',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Email textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0,
                          right:
                              20.0), // Ajuste agregado para el padding derecho
                      child: TextField(
                        controller: _emailController,
                        textAlign: TextAlign
                            .left, // Esta es la línea clave para centrar el texto
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Correo',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // passsword textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0,
                          right:
                              20.0), // Ajuste agregado para el padding derecho
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        textAlign: TextAlign
                            .left, // Esta es la línea clave para centrar el texto
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Contraseña',
                        ),
                      ),
                    ),
                  ),
                ),

                // Instrucción para el usuario sobre el password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '  (Ingresa al menos 8 caracteres)',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(height: 0),

                // passsword textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0,
                          right:
                              20.0), // Ajuste agregado para el padding derecho
                      child: TextField(
                        controller: _confirmpasswordController,
                        obscureText: true,
                        textAlign: TextAlign
                            .left, // Esta es la línea clave para centrar el texto
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Confirma tu contraseña',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),

                //sign in button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100.0),
                  child: GestureDetector(
                    onTap: signUp,
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Registrarse',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Ya tienes una cuenta? inicia sesión
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ya tienes una cuenta?',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Text(
                        ' Inicia Sesión',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
