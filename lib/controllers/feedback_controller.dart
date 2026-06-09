import 'package:flutter/material.dart';
import '../models/feedback_model.dart';
import '../integration/services/feedback_service.dart';

class FeedbackController extends ChangeNotifier {
  final FeedbackService _feedbackService;
  bool isSubmitting = false;
  String? error;

  FeedbackController(this._feedbackService);

  Future<bool> submitFeedback(FeedbackModel feedback) async {
    isSubmitting = true;
    error = null;
    notifyListeners();
    try {
      await _feedbackService.submitFeedback(feedback);
      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
