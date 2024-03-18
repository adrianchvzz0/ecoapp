// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print(
          "Error de Firebase Auth: ${e.code}"); // Esto imprimirá el código de error en la consola.
      String errorMessage;

      switch (e.code) {
        case 'invalid-email':
          errorMessage =
              'No se encontró una cuenta para ese correo electrónico.';
          break;
        case 'invalid-credential':
          errorMessage = 'El usuario o la contraseña son incorrectos';
          break;
        case 'too-many-requests':
          errorMessage = 'Límite de intentos excedidos, inténtalo más tarde';
        case 'channel-error':
          errorMessage = 'Por favor llene todos los campos';
        default:
          errorMessage =
              'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.';
      }

      // Mostrar el mensaje de error en un AlertDialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Error al iniciar sesión',
            style: TextStyle(color: Colors.white), // Color del texto del título
          ),
          content: Text(
            errorMessage,
            style: TextStyle(
                color: Colors.grey[200]), // Color del texto del contenido
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cierra el diálogo
              child: Text(
                'OK',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
          backgroundColor: Colors.blueGrey[900],
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                            .center, // Esta es la línea clave para centrar el texto
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Correo',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

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
                            .center, // Esta es la línea clave para centrar el texto
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Contraseña',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                //sign in button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100.0),
                  child: GestureDetector(
                    onTap: signIn,
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Iniciar Sesión',
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

                // You don´t have an account? Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No tienes una cuenta?',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.showRegisterPage,
                      child: Text(
                        ' Regístrate!',
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
