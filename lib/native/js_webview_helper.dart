// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert'; // For jsonEncode

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Helper class to manage the headless webview for JSNativeWorker
class JSWebviewHelper {
  // Singleton implementation
  factory JSWebviewHelper() => _instance;
  JSWebviewHelper._internal();
  static final JSWebviewHelper _instance = JSWebviewHelper._internal();

  HeadlessInAppWebView? _headlessWebView;
  InAppWebViewController? _webViewController;
  bool _isHeadlessWebviewInitialized = false; // Mirrored name
  Completer<void>? _initializationCompleter;

  static const String _workerHostHTMLPath = "web/worker_js/index.html";

  bool get isInitialized => _isHeadlessWebviewInitialized; // Mirrored name

  Future<void> ensureInitialized() async {
    print(
        'JSWebviewHelper: ensureInitialized called. Current state: _isHeadlessWebviewInitialized: $_isHeadlessWebviewInitialized');
    if (_isHeadlessWebviewInitialized) {
      print(
          'JSWebviewHelper: ensureInitialized - Already initialized. Returning.');
      return;
    }
    if (_initializationCompleter == null) {
      print(
          'JSWebviewHelper: ensureInitialized - Completer is null. Calling initialize().');
      initialize(); // Start initialization if not already started
    } else {
      print(
          'JSWebviewHelper: ensureInitialized - Completer exists. isCompleted: ${_initializationCompleter!.isCompleted}');
    }
    print(
        'JSWebviewHelper: ensureInitialized - Awaiting _initializationCompleter.future.');
    await _initializationCompleter!.future;
    print(
        'JSWebviewHelper: ensureInitialized - _initializationCompleter.future completed. State: $_isHeadlessWebviewInitialized');
  }

  void initialize() {
    print('JSWebviewHelper: initialize() called.');
    // Prevent multiple initializations if already in progress
    if (_initializationCompleter != null &&
        !_initializationCompleter!.isCompleted) {
      print(
          'JSWebviewHelper: initialize() - Initialization already in progress. Returning.');
      return;
    }

    _initializationCompleter = Completer<void>();
    print('JSWebviewHelper: initialize() - New completer created.');

    if (_isHeadlessWebviewInitialized) {
      print(
          'JSWebviewHelper: initialize() - Already initialized (state was true). Completing new completer and returning.');
      if (!_initializationCompleter!.isCompleted) {
        _initializationCompleter!.complete();
      }
      return;
    }

    print(
        'JSWebviewHelper: Initializing HeadlessInAppWebView for $_workerHostHTMLPath');

    try {
      _headlessWebView = HeadlessInAppWebView(
        initialFile: _workerHostHTMLPath,
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          allowFileAccessFromFileURLs: true,
          allowUniversalAccessFromFileURLs: true,
          // useHybridComposition:
          //     true, // Keep for macOS, can be platform-conditional if needed
          // Consider adding other settings from AnalyzerWebviewHelper if relevant
          // transparentBackground: true,
          // supportZoom: false,
          // disableContextMenu: true,
          // disableHorizontalScroll: true,
          // disableVerticalScroll: true,
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
          print('JSWebviewHelper: WebView controller created successfully.');
        },
        onLoadStart: (controller, url) {
          print(
              'JSWebviewHelper: onLoadStart - URL: ${url?.toString() ?? 'null'}');
        },
        onLoadStop: (controller, url) async {
          final loadedUrl = url?.toString() ?? '';
          print(
              'JSWebviewHelper: onLoadStop - URL: $loadedUrl. Controller is ${_webViewController != null ? 'set' : 'null'}');

          // Check if the loaded URL is our main HTML asset file
          if (loadedUrl.contains(_workerHostHTMLPath)) {
            print(
                'JSWebviewHelper: onLoadStop - Worker host HTML loaded: $loadedUrl');
            if (!_isHeadlessWebviewInitialized) {
              // Check flag before setting and completing
              _isHeadlessWebviewInitialized = true;
              print(
                  'JSWebviewHelper: onLoadStop - Set _isHeadlessWebviewInitialized = true.');
              if (!_initializationCompleter!.isCompleted) {
                _initializationCompleter!.complete();
                print(
                    'JSWebviewHelper: onLoadStop - Initialization completer COMPLETED SUCCESSFULLY.');
              } else {
                print(
                    'JSWebviewHelper: onLoadStop - Initialization completer was already completed.');
              }
            } else {
              print(
                  'JSWebviewHelper: onLoadStop - _isHeadlessWebviewInitialized was already true.');
              // If it was already initialized and somehow onLoadStop is called again for the main file,
              // ensure the completer is complete if it's the current one.
              if (_initializationCompleter != null &&
                  !_initializationCompleter!.isCompleted) {
                _initializationCompleter!.complete();
                print(
                    'JSWebviewHelper: onLoadStop - Completed a lingering completer.');
              }
            }
            print(
                'JSWebviewHelper: onLoadStop - Exiting for $_workerHostHTMLPath. State: $_isHeadlessWebviewInitialized');
          } else if (loadedUrl.isNotEmpty) {
            print(
                'JSWebviewHelper: onLoadStop - Loaded a different/intermediate URL: $loadedUrl');
          }
        },
        onLoadError: (controller, url, code, message) {
          print(
              'JSWebviewHelper: onLoadError - URL: ${url?.toString()}, Code: $code, Message: $message');
          if (!_initializationCompleter!.isCompleted) {
            _initializationCompleter!.completeError(StateError(
                'Failed to load URL: $url, Error: $message (Code: $code)'));
            print(
                'JSWebviewHelper: onLoadError - Initialization completer COMPLETED WITH ERROR.');
          }
          // _isHeadlessWebviewInitialized remains false
        },
        onConsoleMessage: (controller, consoleMessage) {
          print(
              "JSWebviewHelper WebView Console - ${consoleMessage.messageLevel}: ${consoleMessage.message}");
        },
        onJsAlert: (controller, jsAlertRequest) async {
          print("JSWebviewHelper JS Alert: ${jsAlertRequest.message}");
          return JsAlertResponse(
              handledByClient: true, action: JsAlertResponseAction.CONFIRM);
        },
        onJsConfirm: (controller, jsConfirmRequest) async {
          print("JSWebviewHelper JS Confirm: ${jsConfirmRequest.message}");
          return JsConfirmResponse(
              handledByClient: true, action: JsConfirmResponseAction.CONFIRM);
        },
        onJsPrompt: (controller, jsPromptRequest) async {
          print("JSWebviewHelper JS Prompt: ${jsPromptRequest.message}");
          return JsPromptResponse(
              handledByClient: true, action: JsPromptResponseAction.CONFIRM);
        },
      );

      print('JSWebviewHelper: Attempting to run headless webview...');

      // Timeout for logging if onLoadStop doesn't fire
      const timeoutDuration = Duration(seconds: 20);
      Future.delayed(timeoutDuration, () {
        if (!_isHeadlessWebviewInitialized &&
            !_initializationCompleter!.isCompleted) {
          print(
              'JSWebviewHelper: WARNING - Initialization TIMEOUT ($timeoutDuration) reached. onLoadStop/Error might not have fired. Completer not done.');
          // Optionally complete with error here if strict timeout is needed for the completer itself
          // _initializationCompleter!.completeError(TimeoutException("Initialization process timed out"));
        } else if (!_isHeadlessWebviewInitialized &&
            _initializationCompleter!.isCompleted) {
          print(
              'JSWebviewHelper: WARNING - Initialization TIMEOUT ($timeoutDuration) reached. Completer is DONE but still not initialized. This indicates an error path completion.');
        } else if (_isHeadlessWebviewInitialized) {
          print(
              'JSWebviewHelper: Initialization TIMEOUT ($timeoutDuration) check: Already initialized.');
        }
      });

      _headlessWebView?.run().then((_) {
        print('JSWebviewHelper: HeadlessInAppWebView run() call completed.');
        // No explicit loadURL needed as initialFile is used.
      }).catchError((error, stackTrace) {
        print(
            'JSWebviewHelper: HeadlessInAppWebView run() FAILED: $error\n$stackTrace');
        if (!_initializationCompleter!.isCompleted) {
          _initializationCompleter!.completeError(error);
          print(
              'JSWebviewHelper: run().catchError - Initialization completer COMPLETED WITH ERROR.');
        }
      });
    } catch (e, stackTrace) {
      print(
          'JSWebviewHelper: Error during HeadlessInAppWebView setup: $e\n$stackTrace');
      if (!_initializationCompleter!.isCompleted) {
        _initializationCompleter!.completeError(e);
        print(
            'JSWebviewHelper: Main try/catch - Initialization completer COMPLETED WITH ERROR.');
      }
    }
  }

  Future<dynamic> evaluateJavascript({required String source}) async {
    print('JSWebviewHelper: evaluateJavascript called. Source: $source');
    await ensureInitialized();
    print(
        'JSWebviewHelper: evaluateJavascript - ensureInitialized completed. State: $_isHeadlessWebviewInitialized');
    if (!_isHeadlessWebviewInitialized || _webViewController == null) {
      print(
          'JSWebviewHelper: evaluateJavascript ERROR - Not initialized or controller is null. State: _isHeadlessWebviewInitialized: $_isHeadlessWebviewInitialized, controller: ${_webViewController != null}');
      throw StateError(
          "JSWebviewHelper: WebView not initialized or controller is null for evaluateJavascript.");
    }

    try {
      print(
          'JSWebviewHelper: evaluateJavascript - AWAITING JS execution for: $source');
      final result =
          await _webViewController!.evaluateJavascript(source: source);
      print(
          'JSWebviewHelper: evaluateJavascript - JS execution COMPLETED for: $source. Result: $result');
      return result;
    } catch (e) {
      print('JSWebviewHelper: evaluateJavascript ERROR for "$source": $e');
      rethrow;
    }
  }

  /// Disposes the headless webview resources
  void dispose() {
    print(
        'JSWebviewHelper: dispose() called. State: _isHeadlessWebviewInitialized: $_isHeadlessWebviewInitialized');
    _headlessWebView?.dispose();
    _headlessWebView = null;
    _webViewController = null;
    _isHeadlessWebviewInitialized = false;
    if (_initializationCompleter != null &&
        !_initializationCompleter!.isCompleted) {
      print(
          'JSWebviewHelper: dispose() - Completing pending completer with error (disposed).');
      _initializationCompleter!.completeError(
          StateError("JSWebviewHelper disposed during initialization."));
    }
    _initializationCompleter = null; // Allow re-initialization if needed
    print('JSWebviewHelper: Disposed successfully.');
  }

  // ===== Specific JavaScript function wrappers =====

  /// Calls the JavaScript 'sayHello' function with the given name.
  Future<String> sayHello(String name) async {
    final result = await _callJsFunction('sayHello', [name]);
    return result.toString();
  }

  /// Calls the JavaScript 'calculateSum' function with the given numbers.
  Future<int> calculateSum(int a, int b) async {
    final result = await _callJsFunction('calculateSum', [a, b]);
    if (result is int) {
      return result;
    } else if (result is num) {
      return result.toInt();
    }
    try {
      return int.parse(result.toString());
    } catch (e) {
      print(
          "JSWebviewHelper: Error parsing int from JS for calculateSum: $result, error: $e");
      throw FormatException(
          "JSWebviewHelper: Failed to parse int from calculateSum: $result");
    }
  }

  /// Calls the JavaScript 'getDataAsync' function with the given ID.
  /// Returns the data string, or null if an error occurs.
  Future<String?> getDataAsync(int id) async {
    const functionName = 'getDataAsync';
    print('[JSWebviewHelper:$functionName] Starting with id=$id');

    await ensureInitialized();

    if (!_isHeadlessWebviewInitialized || _webViewController == null) {
      print(
          '[JSWebviewHelper:$functionName] Cannot execute: webview not properly initialized');
      return null;
    }

    // Create a completer to handle the async result via the JavaScript handler
    final completer = Completer<String?>();

    // Set up a handler for onDataFetched if not already done
    // This is typically done when the controller is created, but we check again
    // to ensure the handler exists
    _webViewController?.addJavaScriptHandler(
        handlerName: 'onDataFetched',
        callback: (args) {
          print(
              '[JSWebviewHelper:$functionName] onDataFetched received: $args');

          // Check if we have received the expected ID
          if (args.length >= 2 && args[0] == id) {
            final result = args[1];

            // Check for error
            if (result is String && result.startsWith('__ERROR__:')) {
              final errorMessage = result.substring('__ERROR__:'.length);
              print(
                  '[JSWebviewHelper:$functionName] JS returned error: $errorMessage');

              // Complete with null on error to indicate failure
              if (!completer.isCompleted) {
                completer.complete(null);
              }
            } else {
              // Complete with the result
              print('[JSWebviewHelper:$functionName] Success: result=$result');
              if (!completer.isCompleted) {
                completer.complete(result?.toString());
              }
            }
          }

          // The handler doesn't need to return anything meaningful since
          // we're using the completer to manage the async flow
          return null;
        });

    try {
      // Call the bridge function via evaluateJavascript
      final confirmationMessage = await _webViewController!
          .evaluateJavascript(source: "fetchDataWithCallback($id)");

      print(
          '[JSWebviewHelper:$functionName] Bridge function called: $confirmationMessage');

      // Set a timeout to avoid getting stuck if the callback never comes
      Future.delayed(Duration(seconds: 30), () {
        if (!completer.isCompleted) {
          print('[JSWebviewHelper:$functionName] Timeout waiting for result');
          completer.complete(null);
        }
      });

      // Wait for the result to be received via the JavaScript handler
      return await completer.future;
    } catch (e) {
      print(
          '[JSWebviewHelper:$functionName] Error calling bridge function: $e');
      return null;
    }
  }

  // ===== Private implementation details =====

  /// Internal method to call a JavaScript function with the given name and arguments.
  /// Handles basic argument serialization for synchronous JavaScript functions.
  /// For async functions, use direct implementation like in getDataAsync.
  Future<dynamic> _callJsFunction(
      String jsFunctionName, List<dynamic> jsCallArgs,
      {bool isAsync = false}) async {
    // isAsync parameter kept for backward compatibility but no longer used
    print(
        'JSWebviewHelper: _callJsFunction \'$jsFunctionName\' called with args: $jsCallArgs');
    await ensureInitialized();

    if (!_isHeadlessWebviewInitialized || _webViewController == null) {
      print(
          'JSWebviewHelper: _callJsFunction ERROR - Not initialized or controller is null.');
      throw StateError(
          "JSWebviewHelper: WebView not initialized or controller is null for calling $jsFunctionName.");
    }

    // Convert arguments to JavaScript string representation
    final argsString = jsCallArgs.map((arg) {
      if (arg is String) {
        String encodedArg = jsonEncode(arg);
        String escapedArg = encodedArg
            .substring(1, encodedArg.length - 1)
            .replaceAll("'", "\\\\'");
        return "\'$escapedArg\'";
      }
      return arg.toString();
    }).join(',');

    // Construct the function call
    final scriptToRun = "$jsFunctionName($argsString)";
    print(
        'JSWebviewHelper: _callJsFunction \'$jsFunctionName\' - Script: $scriptToRun');

    try {
      final result =
          await _webViewController!.evaluateJavascript(source: scriptToRun);
      print(
          'JSWebviewHelper: _callJsFunction \'$jsFunctionName\' - COMPLETED. Result: $result');
      return result;
    } catch (e) {
      print('JSWebviewHelper: _callJsFunction \'$jsFunctionName\' - ERROR: $e');
      rethrow;
    }
  }
}
