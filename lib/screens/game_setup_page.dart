import 'package:flutter/material.dart';

class GameSetupPage extends StatelessWidget {
  const GameSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Нова гра')),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Налаштування гри створимо в Уроці 6.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
