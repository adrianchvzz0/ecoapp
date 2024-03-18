import 'dart:async';

class DeviceData {
  final String deviceId;
  final String data;

  DeviceData(this.deviceId, this.data);
}

class DeviceDataService {
  static final DeviceDataService _instance = DeviceDataService._internal();
  final StreamController<DeviceData> _deviceDataStreamController =
      StreamController<DeviceData>.broadcast();

  factory DeviceDataService() => _instance;

  DeviceDataService._internal();

  Stream<DeviceData> get deviceDataStream => _deviceDataStreamController.stream;

  void dispose() {
    _deviceDataStreamController.close();
  }

  void addDeviceData(String deviceId, String data) {
    if (!_deviceDataStreamController.isClosed) {
      _deviceDataStreamController.sink.add(DeviceData(deviceId, data));
    }
  }

  void clearDataForDevice(String deviceId) {
    // Implementa la lógica para limpiar o manejar los datos cuando el dispositivo se desconecta
    // Esto podría ser simplemente enviar un evento especial a través del stream
    if (!_deviceDataStreamController.isClosed) {
      _deviceDataStreamController.sink
          .add(DeviceData(deviceId, "Disconnected"));
    }
  }

  Stream<String> streamForDevice(String deviceId) {
    return deviceDataStream
        .where((deviceData) => deviceData.deviceId == deviceId)
        .map((deviceData) => deviceData.data);
  }
}
