import 'dart:js_interop';
import 'dart:async';


/// These functions will then be compile to javascript called worker.js


// Define the functions in Dart
String _sayHello(String name) {
  // Log to console
  final message = "Hellooooo, $name!";
  print(message);

  // Return the greeting
  return message;
}

int _calculateSum(int a, int b) {
  // Simulate a computation-heavy task
  int result = 0;
  for (int i = 0; i < 1000000; i++) {
    result += (a * i) + (b * i);
  }
  return result;
}

Future<String> _getDataAsync(int id) async {
  // Log to console
  final message = "Fetching data for ID: $id (in worker)";
  print(message);

  // Use a Future for async operations
  return Future.delayed(Duration(milliseconds: 500), () {
    if (id < 0) {
      throw Exception("Invalid ID: $id");
    }

    // Perform some heavy computation
    int result = 0;
    for (int i = 0; i < 5000000; i++) {
      result += (id * i) % 10;
    }

    return "Data for ID $id processed with result: $result";
  });
}

// JavaScript exports - define setters for the global scope
@JS('sayHello')
external set _exportSayHello(JSFunction fn);

@JS('calculateSum')
external set _exportCalculateSum(JSFunction fn);

@JS('getDataAsync')
external set _exportGetDataAsync(JSFunction fn);

// Main entry point needed for Dart compile js
void main() {
  // Export the individual functions to JavaScript
  _exportSayHello = ((JSString name) {
    return _sayHello(name.toDart).toJS;
  }).toJS;

  _exportCalculateSum = ((JSNumber a, JSNumber b) {
    return _calculateSum(a.toDartInt, b.toDartInt).toJS;
  }).toJS;

  _exportGetDataAsync = ((JSNumber id) {
    final promise = _getDataAsync(id.toDartInt).then((result) => result.toJS);
    return promise.toJS;
  }).toJS;

  print('Worker functions exported successfully');
}
