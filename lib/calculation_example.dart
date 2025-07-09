import 'dart:isolate';
import 'package:flutter/material.dart';

class CalculationExample extends StatefulWidget {
  const CalculationExample({super.key});

  @override
  State<CalculationExample> createState() => _CalculationExampleState();
}

class _CalculationExampleState extends State<CalculationExample> {
  late String _result = '';

  void _startHeavyCalculation() async {
    final receivePort = ReceivePort();
    await Isolate.spawn(calculateSum, receivePort.sendPort);

    final result = await receivePort.first;
    setState(() {
      _result = 'Sum is $result';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Heavy Calculation')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/samples/sun.gif"),
            ElevatedButton(
              onPressed: _startHeavyCalculation,
              child: Text('Start Heavy Calculation'),
            ),
            SizedBox(height: 30),
            Text(_result),
          ],
        ),
      ),
    );
  }
}

void calculateSum(SendPort sendPort) {
  int sum = 0;
  for (int i = 1; i <= 1000000000; i++) {
    sum += i;
  }
  sendPort.send(sum);
}
