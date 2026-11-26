import 'package:flutter/material.dart';

import '../data/local_profile_store.dart';
import '../domain/local_player_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _store = createLocalProfileStore();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  var _avatar = ProfileAvatar.terminal;
  LocalPlayerProfile? _profile;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _store.load();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _nameController.text = profile.displayName;
        _avatar = profile.avatar;
      });
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не вдалося завантажити профіль.')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false) || _profile == null) {
      return;
    }
    setState(() => _isSaving = true);
    final profile = _profile!.copyWith(
      displayName: _nameController.text,
      avatar: _avatar,
    );
    try {
      await _store.save(profile);
      if (!mounted) return;
      setState(() => _profile = profile);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Профіль збережено.')));
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не вдалося зберегти профіль.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Мій профіль')),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(child: _ProfileAvatar(avatar: _avatar, size: 104)),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      maxLength: 24,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Ваше ім’я або псевдонім',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Введіть ім’я або псевдонім.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Оберіть аватар',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final avatar in ProfileAvatar.values)
                          ChoiceChip(
                            selected: _avatar == avatar,
                            onSelected: (_) => setState(() => _avatar = avatar),
                            label: _ProfileAvatar(avatar: avatar, size: 44),
                          ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Профіль збережено лише на цьому пристрої. Обліковий запис та інтернет не потрібні.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Створено: ${_dateLabel(profile.createdAt)}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      child: Text(
                        _isSaving ? 'Збереження…' : 'Зберегти профіль',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _dateLabel(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.avatar, required this.size});

  final ProfileAvatar avatar;
  final double size;

  IconData get _icon => switch (avatar) {
    ProfileAvatar.terminal => Icons.terminal_rounded,
    ProfileAvatar.code => Icons.code_rounded,
    ProfileAvatar.lightbulb => Icons.lightbulb_rounded,
    ProfileAvatar.rocket => Icons.rocket_launch_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(_icon, size: size * 0.55),
    );
  }
}
