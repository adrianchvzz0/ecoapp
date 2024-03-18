// Importaciones necesarias
// ignore_for_file: prefer_const_constructors

import 'package:ecoapp/styles/theme.dart';
import 'package:ecoapp/widgets/services/DeviceDataService.dart';
import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';

class HomePageBody extends StatelessWidget {
  final String userName;
  final List<String> devices;
  final int currentIndex;
  final Function(int) onPageChanged;

  const HomePageBody({
    Key? key,
    required this.userName,
    required this.devices,
    required this.currentIndex,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceDataService = DeviceDataService();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Hola, $userName!\n",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: "Bienvenido de nuevo",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 30),
              child: Text(
                'Mis dispositivos LIAJJ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 5),
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: PageView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: devices.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  return StreamBuilder<String>(
                    stream: deviceDataService.streamForDevice(devices[
                        index]), // Asegúrate de que este stream es el correcto para el dispositivo en 'index'.
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        // Supongamos que tu stream retorna "Agua detectada" o "Sin agua"
                        String status = snapshot.data!;
                        return Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color: Color(0xFF007DCF),
                              borderRadius: BorderRadius.circular(55.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  status, // Mostrando el estado actual según el sensor de agua.
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        // Muestra un indicador de carga mientras esperas los datos.
                        return Center(
                            child:
                                CircularProgressIndicator(color: primaryColor));
                      }
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: DotsIndicator(
                dotsCount: devices.length,
                position: currentIndex,
                decorator: DotsDecorator(
                  activeColor: Colors.white,
                  color: Colors.white.withOpacity(0.5),
                  size: const Size.square(10.0),
                  activeSize: const Size(30.0, 9.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
