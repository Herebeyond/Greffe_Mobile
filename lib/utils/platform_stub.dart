// Web stubs for dart:io classes that are unavailable on the web platform.
// These provide compile-time compatibility; methods are no-ops or throw at runtime.

class HttpOverrides {
  static HttpOverrides? global;
  HttpClient createHttpClient(SecurityContext? context) => HttpClient();
}

class HttpClient {
  set badCertificateCallback(Function? cb) {}
}

class SecurityContext {}

class X509Certificate {}

class File {
  final String path;
  File(this.path);
}
