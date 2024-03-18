// Importaciones necesarias
import 'package:ecoapp/auth/main_page.dart';
import 'package:ecoapp/widgets/services/BluetoothProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'widgets/services/DeviceDataService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Asegúrate de que DeviceDataService se pueda instanciar aquí si es necesario
    DeviceDataService deviceDataService = DeviceDataService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BluetoothProvider(deviceDataService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainPage(),
      ),
    );
  }
}
