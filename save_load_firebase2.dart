import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'auth_service.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  final AuthService _authService = AuthService();
  DatabaseReference? _dbRef;
  int _count = 0;
  bool _isLoading = true;
  Stream<DatabaseEvent>? _counterStream;

  @override
  void initState() {
    super.initState();
    _authService.userStream.listen((user) {
      if (user != null) {
        _setupDatabase(user);
      }
    });
  }

  void _setupDatabase(User user) {
    _dbRef = FirebaseDatabase.instance.ref("counters/${user.uid}");

    _counterStream = _dbRef!.onValue;
    _counterStream!.listen((event) {
      final value = event.snapshot.value as int?;
      setState(() {
        _count = value ?? 0;
        _isLoading = false;
      });
    });
  }

  Future<void> _saveCounter() async {
    await _dbRef!.set(_count);
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
    return StreamBuilder<User?>(
      stream: _authService.userStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // 🔹 ยังไม่ได้ล็อกอิน → แสดงปุ่ม Login
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _authService.signInWithGoogle();
                },
                child: const Text("Login with Google"),
              ),
            ),
          );
        }

        // 🔹 ล็อกอินแล้ว → แสดง Counter
        return Scaffold(
          appBar: AppBar(
            title: const Text("My Counter"),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _authService.signOut(),
              ),
            ],
          ),
          body: Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : Text('$_count', style: const TextStyle(fontSize: 48)),
          ),
          floatingActionButton: _isLoading
              ? null
              : Column(
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
      },
    );
  }
}
