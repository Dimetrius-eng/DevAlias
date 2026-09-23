import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

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
      theme: AppTheme.light,
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
              Text(
                'IT-гра для команд і справжніх девелоперів',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
