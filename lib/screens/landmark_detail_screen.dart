import 'package:flutter/material.dart';
import '../models/landmark.dart';

class LandmarkDetailScreen extends StatelessWidget {
  final Landmark landmark;

  const LandmarkDetailScreen({super.key, required this.landmark});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                landmark.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                ),
              ),
              background: _LandmarkPlaceholderImage(
                category: landmark.category,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icon: Icons.location_on,
                    color: colorScheme.primary,
                    text: landmark.city.isNotEmpty ? landmark.city : '—',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.history,
                    color: colorScheme.secondary,
                    text: landmark.period.isNotEmpty ? landmark.period : '—',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.category,
                    color: colorScheme.tertiary,
                    text: landmark.category,
                  ),
                  const Divider(height: 32),
                  Text(
                    'Hakkında',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    landmark.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.6),
                  ),
                  if (landmark.latitude != null && landmark.longitude != null)
                    _MapSection(landmark: landmark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _MapSection extends StatelessWidget {
  final Landmark landmark;

  const _MapSection({required this.landmark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text(
          'Konum',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 36,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  '${landmark.latitude!.toStringAsFixed(4)}, '
                  '${landmark.longitude!.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LandmarkPlaceholderImage extends StatelessWidget {
  final String category;

  const _LandmarkPlaceholderImage({required this.category});

  IconData _iconFor(String category) {
    switch (category) {
      case 'Dini Yapı':
        return Icons.mosque;
      case 'Saray':
        return Icons.castle;
      case 'Antik Kent':
      case 'Antik Yapı':
        return Icons.account_balance;
      case 'Kale':
        return Icons.fort;
      case 'Doğal Miras':
        return Icons.landscape;
      case 'Arkeolojik Alan':
        return Icons.emoji_nature;
      case 'Tarihi Kent':
      case 'Tarihi Yapı':
        return Icons.location_city;
      default:
        return Icons.museum;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _iconFor(category),
          size: 80,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
