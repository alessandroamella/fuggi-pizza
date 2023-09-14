import 'package:path/path.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSettings {
  final String serverAddress;
  final int serverPort;

  LocalSettings({
    required this.serverAddress,
    required this.serverPort,
  });
}

class LocalSettingsDatabase {
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      return _prefs!;
    } else {
      return _prefs!;
    }
  }

  Future<void> insertLocalSettings(LocalSettings settings) async {
    final prefs = await _getPrefs();
    await prefs.setString('serverAddress', settings.serverAddress);
    await prefs.setInt('serverPort', settings.serverPort);
  }

  Future<LocalSettings?> getLocalSettings() async {
    final prefs = await _getPrefs();
    final serverAddress = prefs.getString('serverAddress');
    final serverPort = prefs.getInt('serverPort');

    if (serverAddress == null || serverPort == null) {
      return null;
    }

    return LocalSettings(
      serverAddress: serverAddress,
      serverPort: serverPort,
    );
  }

  Future<void> deleteLocalSettings() async {
    final prefs = await _getPrefs();
    await prefs.remove('serverAddress');
    await prefs.remove('serverPort');
  }
}
