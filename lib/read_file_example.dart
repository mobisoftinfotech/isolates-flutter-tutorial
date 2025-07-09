import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReadFileExample extends StatefulWidget {
  const ReadFileExample({super.key});

  @override
  ReadFileExampleState createState() => ReadFileExampleState();
}

class ReadFileExampleState extends State<ReadFileExample> {
  String _processedData = "File processing";

  Future<void> createIsolate() async {
    final receivePort = ReceivePort();

    await Isolate.spawn(
      _readFileIsolate,
      receivePort.sendPort,
    );

    final sendPort = await receivePort.first as SendPort;
    final answerPort = ReceivePort();
    String textData = await _loadAssetTextFile();
    sendPort.send([textData, answerPort.sendPort]);
    final result = await answerPort.first;
    setState(() {
      _processedData = result as String;
    });
  }

  Future<String> _loadAssetTextFile() async {
    String data =
        await rootBundle.loadString('assets/samples/sampleText.txt');
    return data;
  }

  static void _readFileIsolate(SendPort mainSendPort) async {
    final port = ReceivePort();
    mainSendPort.send(port.sendPort);
    await for (final message in port) {
      final String textData = message[0];
      final SendPort replyTo = message[1];
      String content = textData.toUpperCase();
      replyTo.send(content);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Read File')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/samples/sun.gif"),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                    _processedData,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: createIsolate,
                child: Text('Start Text Processing'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
