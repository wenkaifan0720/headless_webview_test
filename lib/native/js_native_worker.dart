import 'dart:async';
// import 'dart:convert'; // No longer needed here
// import 'package:flutter/services.dart' show rootBundle; // No longer needed here
// import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // No longer needed here

import '../js_worker.dart';
import 'js_webview_helper.dart'; // Import the new helper

/// Create a native implementation of JSWorker
JSWorker createWorker() => JSNativeWorker();

/// Native implementation of JSWorker using a headless WebView, managed by JSWebviewHelper
class JSNativeWorker implements JSWorker {
  // Use final for the helper as it will be created once.
  final JSWebviewHelper _webviewHelper;

  // Private constructor for singleton or internal instantiation pattern
  JSNativeWorker._internal() : _webviewHelper = JSWebviewHelper();

  // Singleton instance - inspired by AnalyzerNativeWorker
  // This ensures only one worker and its associated webview helper exist.
  static final JSNativeWorker _instance = JSNativeWorker._internal();

  // Factory constructor to return the singleton instance
  factory JSNativeWorker() => _instance;

  @override
  Future<void> initialize() async {
    // The helper now manages its own initialization state internally via ensureInitialized.
    // JSNativeWorker's initialize method effectively becomes a call to the helper's ensureInitialized.
    print('JSNativeWorker: Initializing (delegating to helper)...');
    await _webviewHelper.ensureInitialized();
    print('JSNativeWorker: Initialization complete (delegated to helper).');
  }

  @override
  Future<String> sayHello(String name) async {
    await _webviewHelper.ensureInitialized(); // Ensure helper is ready
    return await _webviewHelper.sayHello(name);
  }

  @override
  Future<int> calculateSum(int a, int b) async {
    await _webviewHelper.ensureInitialized(); // Ensure helper is ready
    return await _webviewHelper.calculateSum(a, b);
  }

  @override
  Future<String> getDataAsync(int id) async {
    await _webviewHelper.ensureInitialized(); // Ensure helper is ready
    final result = await _webviewHelper.getDataAsync(id);
    return result ??
        "Error: Failed to get data for ID $id"; // Provide fallback for null
  }

  @override
  Future<void> dispose() async {
    // No async operation here, dispose is synchronous on the helper for now.
    // If helper.dispose becomes async, this should be awaited.
    _webviewHelper.dispose();
    print('JSNativeWorker: Disposed (delegated to helper).');
  }

  // _ensureInitialized is no longer needed here as each method calls helper.ensureInitialized
  // or the helper itself manages its state internally.
}
