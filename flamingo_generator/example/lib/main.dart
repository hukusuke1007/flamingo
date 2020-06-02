import 'package:flamingo_generator_example/model/index.dart';
import 'package:flutter/material.dart';

void main() {
  final a = UserFieldValueKey.cartA.value;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Center(
          child: Text('Hello'),
        ),
      ),
    );
  }
}
