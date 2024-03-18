// Importaciones necesarias
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:typed_data';
import '../styles/theme.dart'; // Asegúrate de que esta ruta sea correcta
import '../widgets/services/BluetoothProvider.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothDevicesPage extends StatefulWidget {
  @override
  _BluetoothDevicesPageState createState() => _BluetoothDevicesPageState();
}

class _BluetoothDevicesPageState extends State<BluetoothDevicesPage> {
  List<BluetoothDiscoveryResult> _devicesList = [];
  Map<String, String> _deviceConnectionState = {};
  Map<String, BluetoothConnection> _activeConnections = {};
  bool _isDiscovering = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _loadConnectedDevicesUI();
    _initBluetooth();
  }

  void _requestPermission() async {
    await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect
    ].request();
  }

  void _initBluetooth() {
    FlutterBluetoothSerial.instance.state.then((state) {
      if (state == BluetoothState.STATE_ON) {
        startDiscovery();
      } else {
        showBluetoothDisabledDialog();
      }
    });
  }

  Future<void> _loadConnectedDevicesUI() async {
    List<String> connectedDevicesAddresses = await loadConnectedDevices();
    setState(() {
      for (String address in connectedDevicesAddresses) {
        _deviceConnectionState[address] = "Desconectar";
      }
    });
  }

  void _startDataListener(BluetoothConnection connection) {
    connection.input!.listen((Uint8List data) {
      // Aquí puedes implementar la lógica para manejar los datos recibidos.
      // Por ejemplo, puedes enviar estos datos a otra página o widget.
      print('Datos recibidos: ${String.fromCharCodes(data)}');
    }).onDone(() {
      print('Desconectado por el dispositivo remoto');
    });
  }

  Future<void> saveConnectedDevices(List<String> addresses) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('connectedDevices', addresses);
  }

  Future<List<String>> loadConnectedDevices() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('connectedDevices') ?? [];
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(device.address);
      print('Conectado al dispositivo ${device.name}');
      _startDataListener(connection);

      Provider.of<BluetoothProvider>(context, listen: false)
          .addConnectedDevice(device);

      setState(() {
        _deviceConnectionState[device.address] = "Desconectar";
        _activeConnections[device.address] = connection;
      });

      List<String> connectedDevices = await loadConnectedDevices();
      if (!connectedDevices.contains(device.address)) {
        connectedDevices.add(device.address);
        saveConnectedDevices(connectedDevices);
      }
    } catch (e) {
      setState(() => _deviceConnectionState[device.address] = "Error");
      print("Error conectando a dispositivo: $e");
    }
  }

  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar desconexión",
              style: TextStyle(color: whiteColor)),
          content: Text(
              "¿Estás seguro de que quieres desconectar el dispositivo ${device.name}?",
              style: TextStyle(color: whiteColor)),
          actions: <Widget>[
            TextButton(
              child: Text("Cancelar", style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Desconectar", style: TextStyle(color: Colors.blue)),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(
                    () => _deviceConnectionState[device.address] = "Conectar");
                Provider.of<BluetoothProvider>(context, listen: false)
                    .removeConnectedDevice(device);
                await _activeConnections[device.address]?.close();
                setState(() => _deviceConnectionState.remove(device.address));
                List<String> connectedDevices = await loadConnectedDevices();
                connectedDevices.remove(device.address);
                saveConnectedDevices(connectedDevices);
              },
            ),
          ],
          backgroundColor: Colors.blueGrey[900],
        );
      },
    );
  }

  Future<void> startDiscovery() async {
    List<String> connectedDevices = await loadConnectedDevices();
    _devicesList.removeWhere(
        (result) => connectedDevices.contains(result.device.address));
    _isDiscovering = true;
    setState(() {});

    var discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      if (!_devicesList
          .any((element) => element.device.address == r.device.address)) {
        setState(() => _devicesList.add(r));
      }
    });

    Future.delayed(Duration(seconds: 10), () {
      discoveryStreamSubscription.cancel();
      FlutterBluetoothSerial.instance.cancelDiscovery();
      setState(() => _isDiscovering = false);
    });
  }

  void stopDiscovery() {
    FlutterBluetoothSerial.instance.cancelDiscovery();
    setState(() => _isDiscovering = false);
  }

  void showBluetoothDisabledDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Bluetooth desactivado",
              style: TextStyle(color: Colors.white)),
          content: Text("Por favor, activa el Bluetooth para continuar.",
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              child: Text("Activar", style: TextStyle(color: Colors.blue)),
              onPressed: () {
                FlutterBluetoothSerial.instance.requestEnable().then((_) {
                  Navigator.of(context).pop();
                  startDiscovery();
                }).catchError((e) => Navigator.of(context).pop());
              },
            ),
            TextButton(
              child: Text("Cancelar", style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          backgroundColor: Colors.blueGrey[900],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dispositivos Bluetooth',
            style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            icon: Icon(
                _isDiscovering ? Icons.stop_rounded : Icons.refresh_rounded,
                color: Colors.white),
            onPressed: () =>
                _isDiscovering ? stopDiscovery() : startDiscovery(),
          ),
        ],
        backgroundColor: Color(0xFF007DCF),
      ),
      body: _devicesList.isEmpty
          ? Center(
              child: Text("No se encontraron dispositivos.",
                  style: TextStyle(color: Colors.grey[500])))
          : ListView.builder(
              itemCount: _devicesList.length,
              itemBuilder: (context, index) {
                BluetoothDiscoveryResult result = _devicesList[index];
                String deviceAddress = result.device.address;
                String connectionState =
                    _deviceConnectionState[deviceAddress] ?? "Conectar";
                return ListTile(
                  title: Text(result.device.name ?? "Dispositivo desconocido",
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text(deviceAddress,
                      style: TextStyle(color: Colors.grey[600])),
                  trailing: ElevatedButton(
                    onPressed: connectionState == "Conectar"
                        ? () => connectToDevice(result.device)
                        : () => disconnectFromDevice(result.device),
                    child: Text(connectionState,
                        style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>((states) =>
                                connectionState == "Desconectar"
                                    ? Colors.red
                                    : Colors.blue)),
                  ),
                );
              },
            ),
      backgroundColor: backgroundColor,
    );
  }
}
