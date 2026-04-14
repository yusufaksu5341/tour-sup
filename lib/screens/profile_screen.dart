import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 52,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'TourSup',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _SectionCard(
            title: 'Dil / Language',
            children: [
              _SettingTile(
                icon: Icons.language,
                label: 'Türkçe',
                trailing: const Icon(Icons.check, color: Colors.green),
              ),
              _SettingTile(
                icon: Icons.language,
                label: 'English',
                trailing: null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Uygulama Hakkında',
            children: [
              _SettingTile(
                icon: Icons.info_outline,
                label: 'TourSup v1.0.0',
                trailing: null,
              ),
              _SettingTile(
                icon: Icons.description_outlined,
                label: 'Derin Öğrenme Tabanlı Turist Destek Sistemi',
                trailing: null,
                subtitle: 'YOLOv8 · GPS · Acil Modülü',
              ),
              _SettingTile(
                icon: Icons.school_outlined,
                label: 'Sosyal Yenilikçilik ve Girişimcilik',
                trailing: null,
                subtitle: 'Akıllı Ulaşım Sistemleri',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Özellikler',
            children: [
              _FeatureTile(
                icon: Icons.camera_alt,
                color: colorScheme.primary,
                label: 'Görsel Rehberlik',
                desc: '50 tarihi mekân · YOLOv8 tanıma',
              ),
              _FeatureTile(
                icon: Icons.local_taxi,
                color: Colors.amber.shade700,
                label: 'Taksi Takip',
                desc: 'GPS tabanlı ücret şeffaflığı',
              ),
              _FeatureTile(
                icon: Icons.sos,
                color: Colors.red,
                label: 'Acil Durum',
                desc: 'Tek dokunuşla konum paylaşımı',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;

  const _SettingTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 12))
          : null,
      trailing: trailing,
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String desc;

  const _FeatureTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
    );
  }
}
