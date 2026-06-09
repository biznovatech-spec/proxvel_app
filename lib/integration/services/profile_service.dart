import '../../models/user_model.dart';
import '../../models/traveler_profile_model.dart';
import '../local/local_storage_service.dart';

class ProfileService {
  final LocalStorageService _storage;
  ProfileService(this._storage);

  Future<UserModel?> getUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _storage.getUser();
  }

  Future<TravelerProfileModel?> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _storage.getProfile();
  }

  Future<void> saveProfile(TravelerProfileModel profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _storage.saveProfile(profile);
  }
}
