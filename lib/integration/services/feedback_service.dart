import '../../models/feedback_model.dart';
import '../local/local_storage_service.dart';

class FeedbackService {
  final LocalStorageService _storage;
  FeedbackService(this._storage);

  Future<void> submitFeedback(FeedbackModel feedback) async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _storage.saveFeedback(feedback);
  }
}
