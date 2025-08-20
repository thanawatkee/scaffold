import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  static const _kCounterKey = 'counter_value';
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _count = prefs.getInt(_kCounterKey) ?? 0;
    });
  }

  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCounterKey, _count);
  }

  Future<void> _increment() async {
    setState(() => _count++);
    await _saveCounter();
  }

  Future<void> _decrement() async {
    setState(() => _count--);
    await _saveCounter();
  }

  Future<void> _reset() async {
    setState(() => _count = 0);
    await _saveCounter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('$_count', style: const TextStyle(fontSize: 48))),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(onPressed: _increment, child: const Icon(Icons.add)),
          const SizedBox(height: 12),
          FloatingActionButton(onPressed: _decrement, child: const Icon(Icons.remove)),
          const SizedBox(height: 12),
          FloatingActionButton(onPressed: _reset, child: const Icon(Icons.restore)),
        ],
      ),
    );
  }
}
