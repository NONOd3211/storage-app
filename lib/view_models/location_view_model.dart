import 'package:flutter/foundation.dart';
import '../models/storage_location.dart';
import '../services/database_service.dart';

class LocationViewModel extends ChangeNotifier {
  final DatabaseService _database = DatabaseService();

  List<StorageLocation> _locations = [];
  List<StorageLocation> get locations => _locations;

  Future<void> loadLocations() async {
    _locations = await _database.getAllLocations();
    notifyListeners();
  }

  Future<void> addLocation(StorageLocation location) async {
    await _database.insertLocation(location);
    await loadLocations();
  }

  Future<void> deleteLocation(StorageLocation location) async {
    if (!location.isPreset) {
      await _database.deleteLocation(location);
      await loadLocations();
    }
  }

  List<String> get locationNames => _locations.map((l) => l.name).toList();
}
