import 'dart:async';

/// Abstract class that defines the interface for JavaScript workers
/// This provides a unified API regardless of platform implementation
abstract class JSWorker {
  /// Initialize the worker
  Future<void> initialize();

  /// Say hello using JavaScript
  Future<String> sayHello(String name);

  /// Calculate sum using JavaScript
  Future<int> calculateSum(int a, int b);

  /// Get data asynchronously using JavaScript
  Future<String> getDataAsync(int id);

  /// Dispose resources
  Future<void> dispose();

  /// Factory constructor to get the appropriate implementation
  /// This will be defined in js_worker_impl.dart
  factory JSWorker() {
    throw UnsupportedError('Use conditional import to create JSWorker');
  }
}
