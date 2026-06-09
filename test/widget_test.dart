import 'package:flutter_test/flutter_test.dart';

import 'package:proxvell_app/app.dart';
import 'package:proxvell_app/integration/local/local_storage_service.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final storageService = LocalStorageService();
    // Build our app and trigger a frame.
    await tester.pumpWidget(ProxvelApp(storageService: storageService));
  });
}
