import 'package:flutter/material.dart';

void main() {
  runApp(const ImpostorApp());
}

class ImpostorApp extends StatelessWidget {
  const ImpostorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Impostor',
      theme: ThemeData.dark(useMaterial3: true),
      home: const Scaffold(
        body: Center(child: Text('Impostor')),
      ),
    );
  }
}
