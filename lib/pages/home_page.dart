// ignore_for_file: sort_child_properties_last, prefer_const_constructors, use_super_parameters
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecoapp/pages/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/dev_bluetooth_page.dart';
import '../styles/theme.dart';
import '../widgets/HomePageBody.dart'; // Asegúrate de usar la ruta correcta.

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class CustomDrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const CustomDrawerTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: whiteColor),
      title: Text(title, style: whiteTextStyle),
      onTap: onTap,
    );
  }
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String userName = "Cargando..."; // Inicializar userName con un valor temporal

  int _currentIndex = 0;

  List<String> devices = [
    "Dispositivo 1",
  ];

  @override
  void initState() {
    super.initState();
    cargarNombreUsuario();
    // Comienza a escuchar los cambios en tiempo real.
  }

  Future<void> cargarNombreUsuario() async {
    final uid = user.uid;
    try {
      DocumentSnapshot usuarioDatos = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();
      if (usuarioDatos.exists) {
        setState(() {
          userName = usuarioDatos
              .get('nombre'); // Asegúrate de que 'nombre' sea el campo correcto
        });
      } else {
        setState(() {
          userName = user.displayName ?? 'Usuario';
        });
      }
    } catch (e) {
      print('Error al cargar el nombre del usuario: $e');
      setState(() {
        userName = user.displayName ?? 'Usuario';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(76.0),
          child: Text(
            'ecoinnova.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, size: 35, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        backgroundColor: Color(0xFF007DCF),
      ),
      drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(userName), // Mostrar el nombre del usuario
                accountEmail: Text(user.email!),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Icon(Icons.person),
                  ),
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF007DCF),
                ),
              ),
              CustomDrawerTile(
                icon: Icons.home,
                title: 'Home',
                onTap: () => Navigator.of(context).pop(),
              ),
              Divider(
                color: Colors.blueGrey[900],
              ),
              CustomDrawerTile(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
              Divider(color: Colors.grey[900]),
              CustomDrawerTile(
                icon: Icons.logout,
                title: 'Cerrar sesión',
                onTap: () {
                  FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
          backgroundColor: backgroundColor2),
      body: HomePageBody(
        userName: userName,
        devices: devices,
        currentIndex: _currentIndex,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      backgroundColor: Color.fromRGBO(0, 11, 22, 1.0),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BluetoothDevicesPage()),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Color(0xFF007DCF),
      ),
    );
  }
}
