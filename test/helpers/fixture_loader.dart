import 'dart:io';

/// Loads asset fixtures from the filesystem during tests.
///
/// The mock interceptor accepts a custom loader so tests don't need
/// to bind a Flutter binding for `rootBundle`.
Future<String> loadFixture(String assetPath) async {
  return File(assetPath).readAsString();
}
