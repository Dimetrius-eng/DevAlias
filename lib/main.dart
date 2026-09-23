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

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Цей розділ з’явиться в наступних уроках.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0, end: 1),
          builder: (context, animationValue, child) {
            return Opacity(
              opacity: animationValue,
              child: Transform.translate(
                offset: Offset(0, 24 * (1 - animationValue)),
                child: child,
              ),
            );
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _DevAliasLogo(),
                  const SizedBox(height: 24),
                  Text(
                    'DevAlias',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'IT-гра для команд і справжніх девелоперів',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 48),
                  FilledButton(
                    onPressed: () => _showComingSoon(context),
                    child: const Text('Нова гра'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _showComingSoon(context),
                    child: const Text('Як грати'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DevAliasLogo extends StatelessWidget {
  const _DevAliasLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Icon(
          Icons.terminal_rounded,
          color: Colors.white,
          size: 64,
        ),
      ),
    );
  }
}
