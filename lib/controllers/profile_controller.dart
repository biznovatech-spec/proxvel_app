import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/traveler_profile_model.dart';
import '../integration/services/profile_service.dart';
import '../integration/local/local_storage_service.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _profileService;
  final LocalStorageService _storageService;
  bool isLoading = false;
  UserModel? user;
  TravelerProfileModel? profile;
  String? error;

  ProfileController(this._profileService, this._storageService);

  Future<void> loadProfileData() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      user = _storageService.getUser();
      profile = _storageService.getProfile();
      
      // Fallback to mock if not registered locally
      user ??= await _profileService.getUser();
      profile ??= await _profileService.getProfile();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> updatePreferences(TravelerProfileModel updatedProfile) async {
    profile = updatedProfile;
    await _storageService.saveProfile(updatedProfile);
    notifyListeners();
  }

  Future<void> logout() async {
    await _storageService.setSessionActive(false);
  }
}
