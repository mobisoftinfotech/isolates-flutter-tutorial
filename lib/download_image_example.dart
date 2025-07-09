import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DownloadImageExample extends StatefulWidget {
  const DownloadImageExample({super.key});

  @override
  State<DownloadImageExample> createState() => DownloadImageExampleState();
}

class DownloadImageExampleState extends State<DownloadImageExample> {
  Uint8List? imageBytes;
  bool isProcessing = false;

  Future<void> downloadImageInIsolate(String url) async {
    setState(() => isProcessing = true);

    final receivePort = ReceivePort();

    await Isolate.spawn(_downloadImage, [url, receivePort.sendPort]);

    imageBytes = await receivePort.first as Uint8List?;

    setState(() => isProcessing = false);
  }

  static Future<void> _downloadImage(List<dynamic> args) async {
    final String url = args[0];
    final SendPort sendPort = args[1];

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      sendPort.send(response.bodyBytes);
    } else {
      sendPort.send(null);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadImageInIsolate(
        'https://cdn.pixabay.com/photo/2023/11/16/05/02/mountains-8391433_640.jpg');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Downloading and Display'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/samples/sun.gif"),
            isProcessing
                ? const CircularProgressIndicator()
                : imageBytes != null
                    ? Image.memory(imageBytes!)
                    : const Text('Failed to load image'),
          ],
        ),
      ),
    );
  }
}
