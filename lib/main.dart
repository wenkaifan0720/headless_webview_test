import 'package:flutter/material.dart';

// Import our JSWorker abstraction
import 'js_worker.dart';
import 'js_worker_impl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: JsTestScreen(),
    );
  }
}

class JsTestScreen extends StatefulWidget {
  const JsTestScreen({Key? key}) : super(key: key);

  @override
  State<JsTestScreen> createState() => _JsTestScreenState();
}

class _JsTestScreenState extends State<JsTestScreen> {
  String _result = '';
  bool _isLoading = false;

  late JSWorker _jsWorker;
  int _computationTime = 0;

  @override
  void initState() {
    super.initState();
    _jsWorker = createJSWorker();
    _initializeWorker();
  }

  Future<void> _initializeWorker() async {
    try {
      await _jsWorker.initialize();
    } catch (e) {
      print('Error initializing worker: $e');
    }
  }

  @override
  void dispose() {
    _jsWorker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JS Interop in Worker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isLoading)
            CircularProgressIndicator()
          else
            Column(
              children: [
                Text(_result, style: TextStyle(fontSize: 18)),
                if (_computationTime > 0)
                  Text('Computation time: ${_computationTime}ms',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              try {
                setState(() {
                  _isLoading = true;
                  _result = '';
                  _computationTime = 0;
                });

                final startTime = DateTime.now().millisecondsSinceEpoch;

                // Call the function via our JSWorker abstraction
                final result = await _jsWorker.sayHello('Flutter');

                final endTime = DateTime.now().millisecondsSinceEpoch;

                setState(() {
                  _result = result;
                  _isLoading = false;
                  _computationTime = endTime - startTime;
                });
              } catch (e) {
                setState(() {
                  _result = "Error: $e";
                  _isLoading = false;
                });
              }
            },
            child: Text('Say Hello (Worker)'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              try {
                setState(() {
                  _isLoading = true;
                  _result = '';
                  _computationTime = 0;
                });

                final startTime = DateTime.now().millisecondsSinceEpoch;

                // Call the function via our JSWorker abstraction
                final sum = await _jsWorker.calculateSum(5, 7);

                final endTime = DateTime.now().millisecondsSinceEpoch;

                setState(() {
                  _result = 'Sum: $sum';
                  _isLoading = false;
                  _computationTime = endTime - startTime;
                });
              } catch (e) {
                setState(() {
                  _result = "Error: $e";
                  _isLoading = false;
                });
              }
            },
            child: Text('Calculate Sum (Worker)'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              try {
                setState(() {
                  _isLoading = true;
                  _result = '';
                  _computationTime = 0;
                });

                final startTime = DateTime.now().millisecondsSinceEpoch;

                // Call the function via our JSWorker abstraction
                final data = await _jsWorker.getDataAsync(42);

                final endTime = DateTime.now().millisecondsSinceEpoch;

                setState(() {
                  _result = data;
                  _isLoading = false;
                  _computationTime = endTime - startTime;
                });
              } catch (e) {
                setState(() {
                  _result = "Error: $e";
                  _isLoading = false;
                });
              }
            },
            child: Text('Fetch Data Async (Worker)'),
          ),
        ],
      ),
    );
  }
}
