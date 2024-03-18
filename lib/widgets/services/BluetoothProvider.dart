import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:ecoapp/widgets/services/DeviceDataService.dart';

class BluetoothProvider with ChangeNotifier {
  List<BluetoothDevice> _connectedDevices = [];
  final DeviceDataService _deviceDataService;

  BluetoothProvider(this._deviceDataService);

  List<BluetoothDevice> get connectedDevices =>
      List.unmodifiable(_connectedDevices);

  void addConnectedDevice(BluetoothDevice device) {
    if (!_connectedDevices.any((d) => d.address == device.address)) {
      _connectedDevices.add(device);
      notifyListeners();
    }
  }

  void removeConnectedDevice(BluetoothDevice device) {
    // Verifica si el dispositivo está presente antes de intentar eliminarlo
    bool deviceExists =
        _connectedDevices.any((d) => d.address == device.address);

    if (deviceExists) {
      _connectedDevices.removeWhere((d) => d.address == device.address);
      // Limpia los datos asociados al dispositivo después de eliminarlo
      _deviceDataService.clearDataForDevice(device.address);
      notifyListeners();
    }
  }
}
