import 'dart:convert';

import '../../../../core/cache/cache_helper.dart';
import '../../../../core/cache/cache_keys.dart';
import '../models/saved_address_model.dart';

class SavedAddressesLocalDataSource {
  const SavedAddressesLocalDataSource._();

  static List<SavedAddressModel> load() {
    final raw = CacheHelper.getString(CacheKeys.savedAddresses);
    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                SavedAddressModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((address) => address.id.trim().isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static Future<void> saveAll(List<SavedAddressModel> addresses) async {
    final normalized = _normalizeDefault(addresses);
    await CacheHelper.setString(
      CacheKeys.savedAddresses,
      jsonEncode(normalized.map((address) => address.toJson()).toList()),
    );
  }

  static Future<void> upsert(SavedAddressModel address) async {
    final addresses = load().toList();
    final index = addresses.indexWhere((item) => item.id == address.id);
    final nextAddress = address.isDefault || addresses.isEmpty
        ? address.copyWith(isDefault: true)
        : address;

    if (index == -1) {
      addresses.add(nextAddress);
    } else {
      addresses[index] = nextAddress;
    }

    await saveAll(addresses);
  }

  static Future<void> delete(String id) async {
    final addresses = load().where((address) => address.id != id).toList();
    await saveAll(addresses);
  }

  static Future<void> setDefault(String id) async {
    final addresses = load()
        .map((address) => address.copyWith(isDefault: address.id == id))
        .toList();
    await saveAll(addresses);
  }

  static SavedAddressModel? defaultAddress() {
    final addresses = load();
    if (addresses.isEmpty) return null;

    for (final address in addresses) {
      if (address.isDefault) return address;
    }

    return addresses.first;
  }

  static List<SavedAddressModel> _normalizeDefault(
    List<SavedAddressModel> addresses,
  ) {
    if (addresses.isEmpty) return const [];

    var defaultApplied = false;
    final normalized = addresses.map((address) {
      final shouldBeDefault = address.isDefault && !defaultApplied;
      if (shouldBeDefault) defaultApplied = true;
      return address.copyWith(isDefault: shouldBeDefault);
    }).toList();

    if (!defaultApplied) {
      normalized[0] = normalized.first.copyWith(isDefault: true);
    }

    return normalized;
  }
}
