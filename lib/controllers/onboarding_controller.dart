import 'package:flutter/material.dart';
import '../models/traveler_profile_model.dart';
import '../integration/services/profile_service.dart';

class OnboardingController extends ChangeNotifier {
  final ProfileService _profileService;
  bool isLoading = false;
  String? error;

  OnboardingController(this._profileService);

  Future<bool> saveProfile(TravelerProfileModel profile, String userId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      // Backend real
      final realProfile = await _profileService.putTravelerProfile(
        userId: userId,
        profile: profile,
      );
      // Cache local temporal
      await _profileService.saveProfile(realProfile);
      
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
