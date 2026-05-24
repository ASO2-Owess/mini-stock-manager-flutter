import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();
  final _avatarCtrl = TextEditingController();
  String _themeColor = '#1A3A5C';
  int? _loadedUserId;

  static const _colors = [
    '#1A3A5C',
    '#229A67',
    '#D45B4A',
    '#7C3AED',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _displayNameCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  void _syncFields(AuthProvider auth) {
    final user = auth.user;
    if (user == null || _loadedUserId == user.id) return;
    _loadedUserId = user.id;
    _nameCtrl.text = user.name;
    _displayNameCtrl.text = user.displayName;
    _avatarCtrl.text = user.avatarLabel;
    _themeColor = user.themeColor;
  }

  Color _parseColor(String value) {
    final hex = value.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await context.read<AuthProvider>().updateProfile(
          name: _nameCtrl.text.trim(),
          displayName: _displayNameCtrl.text.trim(),
          themeColor: _themeColor,
          avatarLabel: _avatarCtrl.text.trim(),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Profil enregistre' : 'Enregistrement impossible'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    _syncFields(auth);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _parseColor(_themeColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  user?.avatarLabel ?? '?',
                  style: TextStyle(
                    color: _parseColor(_themeColor),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user?.email ?? ''} - ${user?.role ?? ''}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Personnalisation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nom requis'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _displayNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom affiche',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _avatarCtrl,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'Initiales',
                    prefixIcon: Icon(Icons.circle_outlined),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  children: [
                    for (final color in _colors)
                      ChoiceChip(
                        label: Text(color),
                        selected: _themeColor == color,
                        avatar: CircleAvatar(
                          backgroundColor: _parseColor(color),
                        ),
                        onSelected: (_) => setState(() => _themeColor = color),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                CustomButton(
                  label: 'Enregistrer mon espace',
                  icon: Icons.save_outlined,
                  loading: auth.loading,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
