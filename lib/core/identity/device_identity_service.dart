import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'device_identity.dart';

class DeviceIdentityService {
  final SharedPreferences _prefs;
  DeviceIdentity? _cached;

  static const _keyId = 'device_identity_id';
  static const _keyCreatedAt = 'device_identity_created_at';
  static const _keyLaunchCount = 'device_launch_count';

  DeviceIdentityService(this._prefs);

  Future<DeviceIdentity> loadOrCreate() async {
    if (_cached != null) return _cached!;

    final id = _prefs.getString(_keyId);
    if (id != null) {
      return _loadExisting();
    }
    return _createNew();
  }

  Future<void> incrementLaunchCount() async {
    final identity = await loadOrCreate();
    final next = identity.launchCount + 1;
    await _prefs.setInt(_keyLaunchCount, next);
    _cached = identity.copyWith(launchCount: next);
  }

  DeviceIdentity _loadExisting() {
    final id = _prefs.getString(_keyId)!;
    final createdAt = DateTime.parse(_prefs.getString(_keyCreatedAt)!);
    final launchCount = _prefs.getInt(_keyLaunchCount) ?? 0;

    _cached = DeviceIdentity(
      anonymousId: id,
      createdAt: createdAt,
      launchCount: launchCount,
    );
    return _cached!;
  }

  Future<DeviceIdentity> _createNew() async {
    final uuid = Uuid().v4();
    final now = DateTime.now();

    await _prefs.setString(_keyId, uuid);
    await _prefs.setString(_keyCreatedAt, now.toIso8601String());
    await _prefs.setInt(_keyLaunchCount, 0);

    _cached = DeviceIdentity(
      anonymousId: uuid,
      createdAt: now,
      launchCount: 0,
    );
    return _cached!;
  }
}
