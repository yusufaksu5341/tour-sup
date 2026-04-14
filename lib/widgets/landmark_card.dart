import 'package:flutter/material.dart';
import '../models/landmark.dart';
import '../screens/landmark_detail_screen.dart';

class LandmarkCard extends StatelessWidget {
  final Landmark landmark;
  final VoidCallback onClose;

  const LandmarkCard({
    super.key,
    required this.landmark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance, color: colorScheme.primary, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    landmark.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: colorScheme.secondary),
                const SizedBox(width: 4),
                Text(
                  '${landmark.city}  •  ${landmark.period}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.secondary,
                      ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              landmark.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          LandmarkDetailScreen(landmark: landmark),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text('Detayları Gör'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
