import 'package:flutter/material.dart';

class HowToPlayPage extends StatelessWidget {
  const HowToPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Як грати')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Правила DevAlias',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 24),
              Text('1. Оберіть команду, яка пояснюватиме слова.'),
              SizedBox(height: 12),
              Text('2. Пояснюйте IT-термін, не називаючи його напряму.'),
              SizedBox(height: 12),
              Text('3. Команда отримує бали за правильні відповіді.'),
            ],
          ),
        ),
      ),
    );
  }
}
