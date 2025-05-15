import 'package:flutter/foundation.dart' show kIsWeb;
import 'js_worker.dart';

// Import with conditional exports
import 'native/js_native_worker.dart' if (dart.library.html) 'web/js_web_worker.dart'
    as worker_impl;


/// Create a JSWorker with the appropriate implementation for the current platform
JSWorker createJSWorker() {
  // The worker is automatically chosen based on the platform
  // due to the conditional import above
  return worker_impl.createWorker();
}
