import 'dart:async';
import '../js_worker.dart';
import 'worker_worker.dart';

/// Create a web implementation of JSWorker
JSWorker createWorker() => JSWebWorker();

/// Web implementation of JSWorker using Squadron
class JSWebWorker implements JSWorker {
  WorkerWorker? _worker;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (!_initialized) {
      _worker = WorkerWorker();
      _initialized = true;
    }
  }

  @override
  Future<String> sayHello(String name) async {
    await _ensureInitialized();

    try {
      // The HelloWorld worker already has 'Flutter' hardcoded in the implementation
      // We're ignoring the name parameter for now, but could modify HelloWorld if needed
      return await _worker!.sayHello();
    } catch (e) {
      print('Error in web worker sayHello: $e');
      return 'Error: $e';
    }
  }

  @override
  Future<int> calculateSum(int a, int b) async {
    await _ensureInitialized();

    try {
      return await _worker!.calculateSum(a, b);
    } catch (e) {
      print('Error in web worker calculateSum: $e');
      return -1;
    }
  }

  @override
  Future<String> getDataAsync(int id) async {
    await _ensureInitialized();

    try {
      return await _worker!.getDataAsync(id);
    } catch (e) {
      print('Error in web worker getDataAsync: $e');
      return 'Error: $e';
    }
  }

  @override
  Future<void> dispose() async {
    if (_worker != null) {
      _worker = null;
      _initialized = false;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized || _worker == null) {
      await initialize();
    }
  }
}
