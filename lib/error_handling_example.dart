import 'dart:isolate';
import 'package:flutter/material.dart';

class ErrorHandlingExample extends StatefulWidget {
  const ErrorHandlingExample({super.key});

  @override
  ErrorHandlingExampleState createState() => ErrorHandlingExampleState();
}

class ErrorHandlingExampleState extends State<ErrorHandlingExample> {
  String _result = '';

  Future<void> _runWithError() async {
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();
    await Isolate.spawn(
      _errorProneIsolate,
      receivePort.sendPort,
      onError: errorPort.sendPort,
    );
    final sendPort = await receivePort.first as SendPort;
    final answerPort = ReceivePort();
    sendPort.send([answerPort.sendPort]); // Listen for errors
    errorPort.listen((error) {
      setState(() {
        _result = 'Error: ${error.toString()}';
      });
    });
    try {
      final result = await answerPort.first;
      setState(() {
        _result = 'Result: $result';
      });
    } catch (e) {
      setState(() {
        _result = 'Caught error: $e';
      });
    }
  }

  static void _errorProneIsolate(SendPort mainSendPort) async {
    final port = ReceivePort();
    mainSendPort.send(port.sendPort);
    await for (final message in port) {
      final SendPort replyTo = message[0]; // Simulate an error
      throw Exception('Something went wrong in the isolate');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Error Handling in Isolate')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/samples/sun.gif"),
            ElevatedButton(
              onPressed: _runWithError,
              child: Text('Run with Error'),
            ),
            SizedBox(height: 20),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
