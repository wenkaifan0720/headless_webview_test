import 'dart:async';
import 'dart:js_interop';
import 'package:squadron/squadron.dart';

import 'worker_worker.activator.g.dart';
part 'worker_worker.worker.g.dart';

// This is a special command to load our worker.js file in the Squadron worker
@JS('importScripts')
external void importScripts(JSString url);

// Define external JavaScript functions that will be available in the worker context
@JS('sayHello')
external JSString _jsSayHello(JSString name);

@JS('calculateSum')
external JSNumber _jsCalculateSum(JSNumber a, JSNumber b);

@JS('getDataAsync')
external JSPromise<JSString> _jsGetDataAsync(JSNumber id);

@SquadronService(baseUrl: '~/workers', targetPlatform: TargetPlatform.web)
// or @SquadronService(baseUrl: '~/workers', targetPlatform: TargetPlatform.all)
base class WorkerWorker {
  // Initialize the worker by loading our JavaScript file
  bool _initialized = false;

  void _ensureInitialized() {
    if (!_initialized) {
      try {
        // Load the JavaScript file into the worker
        importScripts('/worker.js'.toJS);
        print('Worker JavaScript file loaded');
        _initialized = true;
      } catch (e) {
        print('Error loading worker JavaScript: $e');
        rethrow;
      }
    }
  }

  @SquadronMethod()
  FutureOr<String> sayHello() {
    _ensureInitialized();

    try {
      // Call the JavaScript function directly in the worker context
      final jsResult = _jsSayHello('Flutter'.toJS);
      return jsResult.toDart;
    } catch (e) {
      print('Error in sayHello: $e');
      return 'Error calling sayHello in worker: $e';
    }
  }

  @SquadronMethod()
  FutureOr<int> calculateSum(int a, int b) {
    _ensureInitialized();

    try {
      // Call the JavaScript function directly in the worker context
      final jsResult = _jsCalculateSum(a.toJS, b.toJS);
      return jsResult.toDartInt;
    } catch (e) {
      print('Error in calculateSum: $e');
      return -1;
    }
  }

  @SquadronMethod()
  FutureOr<String> getDataAsync(int id) async {
    _ensureInitialized();

    try {
      // Call the JavaScript function directly in the worker context
      final jsPromise = _jsGetDataAsync(id.toJS);

      // Convert JSPromise to Dart Future

      // Await the Future and convert the result to Dart String
      final jsResult = await jsPromise.toDart;
      return jsResult.toDart;
    } catch (e) {
      print('Error in getDataAsync: $e');
      return 'Error calling getDataAsync in worker: $e';
    }
  }
}
