// Conditional export: uses dart:io on native platforms, stubs on web.
export 'platform_stub.dart' if (dart.library.io) 'platform_native.dart';
