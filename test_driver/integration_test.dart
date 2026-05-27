import 'dart:async';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  return integrationDriver(
    timeout: const Duration(minutes: 5),
    responseDataCallback: (data) async {
      if (data == null) return;
      final file = File('build/integration_response_data.json');
      await file.parent.create(recursive: true);
      await file.writeAsString(data.toString());
      stdout.writeln('=== integration response ===\n${data.toString()}\n=== end ===');
    },
  );
}
