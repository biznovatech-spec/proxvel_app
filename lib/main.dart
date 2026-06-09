import 'package:flutter/material.dart';
import 'app.dart';
import 'integration/local/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = LocalStorageService();
  await storageService.init();
  runApp(ProxvelApp(storageService: storageService));
}
