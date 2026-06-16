import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/city_model.dart';

/// Provider to fetch active cities from public API
final activeCitiesProvider = FutureProvider<List<CityModel>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get(ApiConstants.cities);
  
  if (response.statusCode == 200 && response.data != null) {
    final list = response.data['data'] as List;
    return list.map((json) => CityModel.fromJson(json)).toList();
  }
  return [];
});

/// Notifier to manage the customer's selected city with persistent storage
class SelectedCityNotifier extends Notifier<CityModel?> {
  @override
  CityModel? build() {
    _loadPersistedCity();
    return null;
  }

  Future<void> _loadPersistedCity() async {
    const persistentStorage = CityPersistentStorage();
    final cityIdStr = await persistentStorage.readId();
    final cityName = await persistentStorage.readName();
    if (cityIdStr != null && cityName != null) {
      final id = int.tryParse(cityIdStr);
      if (id != null) {
        state = CityModel(id: id, name: cityName);
      }
    }
  }

  Future<void> selectCity(CityModel city) async {
    state = city;
    await const CityPersistentStorage().save(city.id.toString(), city.name);
  }

  Future<void> clearCity() async {
    state = null;
    await const CityPersistentStorage().clear();
  }
}

class CityPersistentStorage {
  static const _storage = FlutterSecureStorage();
  const CityPersistentStorage();
  
  Future<String?> readId() => _storage.read(key: 'selected_city_id');
  Future<String?> readName() => _storage.read(key: 'selected_city_name');
  
  Future<void> save(String id, String name) async {
    await _storage.write(key: 'selected_city_id', value: id);
    await _storage.write(key: 'selected_city_name', value: name);
  }
  
  Future<void> clear() async {
    await _storage.delete(key: 'selected_city_id');
    await _storage.delete(key: 'selected_city_name');
  }
}

final selectedCityProvider = NotifierProvider<SelectedCityNotifier, CityModel?>(() {
  return SelectedCityNotifier();
});
