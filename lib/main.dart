import 'package:flutter/material.dart';

void main() {
  runApp(const DevAliasApp());
}

class DevAliasApp extends StatelessWidget {
  const DevAliasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevAlias',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF635BFF)),
        useMaterial3: true,
      ),
      home: const DevAliasHomePage(),
    );
  }
}

class DevAliasHomePage extends StatelessWidget {
  const DevAliasHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.code_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'DevAlias',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text('IT-гра для команд і справжніх девелоперів'),
            ],
          ),
        ),
      ),
    );
  }
}
