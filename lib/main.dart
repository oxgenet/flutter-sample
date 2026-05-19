import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maestro Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter + Maestro')),
      body: Center(
        child: Text(
          'Counter: $_counter',
          key: const ValueKey('counter_text'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: Semantics(
        button: true,
        container: true,
        excludeSemantics: true,
        identifier: 'increment-counter-button',
        label: 'Increment counter button',
        child: FloatingActionButton.extended(
          onPressed: _incrementCounter,
          tooltip: 'Increment counter',
          icon: const Icon(Icons.add),
          label: const Text('Increment counter'),
        ),
      ),
    );
  }
}
