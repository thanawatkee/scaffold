import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CounterPage(),
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
  String? _imagePath;

  // Key สำหรับบันทึก path ของรูป
  final String _imgKey = "img_counter_0";

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
      _imagePath = prefs.getString(_imgKey);
    });
  }

  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', _counter);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved counter")),
      );
    }
  }

  void _increment() {
    setState(() => _counter++);
  }

  void _decrement() {
    setState(() => _counter--);
  }

  // ถ่ายรูปเฉพาะตอน counter == 0
  Future<void> _captureImage() async {
    if (_counter != 0) return;

    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.camera);
    if (xfile == null) return;

    // copy เก็บใน documents ของแอป
    final dir = await getApplicationDocumentsDirectory();
    final savePath = p.join(dir.path, "counter0${p.extension(xfile.path)}");
    await File(xfile.path).copy(savePath);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_imgKey, savePath);

    setState(() => _imagePath = savePath);
  }

  Widget _buildContent() {
    if (_counter == 0) {
      if (_imagePath != null && File(_imagePath!).existsSync()) {
        return GestureDetector(
          onTap: _captureImage,
          child: Image.file(File(_imagePath!), width: 200, height: 200),
        );
      } else {
        return Column(
          children: [
            const Icon(Icons.photo_camera, size: 100),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _captureImage,
              icon: const Icon(Icons.camera),
              label: const Text("ถ่ายรูปสำหรับ counter = 0"),
            ),
          ],
        );
      }
    } else {
      return Text(
        "$_counter",
        style: const TextStyle(fontSize: 60),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Counter + Camera (0 only)")),
      body: Center(child: _buildContent()),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: _increment,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: _decrement,
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: "btn3",
            onPressed: _saveCounter,
            tooltip: 'Save counter',
            child: const Icon(Icons.save),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: "btn4",
            onPressed: _loadCounter,
            tooltip: 'Load counter',
            child: const Icon(Icons.download),
          ),
        ],
      ),
    );
  }
}
