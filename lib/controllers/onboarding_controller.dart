import 'package:flutter/material.dart';
import '../models/traveler_profile_model.dart';
import '../integration/services/profile_service.dart';

class OnboardingController extends ChangeNotifier {
  final ProfileService _profileService;
  bool isLoading = false;
  String? error;

  OnboardingController(this._profileService);

  Future<bool> saveProfile(TravelerProfileModel profile) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _profileService.saveProfile(profile);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
