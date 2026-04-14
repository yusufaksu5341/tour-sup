import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart' show Share;
import 'package:url_launcher/url_launcher.dart';
import '../services/providers.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  bool _isFetching = false;
  String? _lastCoords;
  DateTime? _lastSentAt;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleSOS() async {
    if (_isFetching) return;
    setState(() => _isFetching = true);

    final locationService = ref.read(locationServiceProvider);
    final granted = await locationService.requestPermission();

    if (!granted) {
      if (mounted) {
        setState(() => _isFetching = false);
        _showError('Konum izni verilmedi. Lütfen ayarlardan izin verin.');
      }
      return;
    }

    final loc = await locationService.getCurrentLocation();

    if (!mounted) return;
    setState(() => _isFetching = false);

    if (loc == null) {
      _showError('Konum alınamadı. GPS sinyalinizi kontrol edin.');
      return;
    }

    final coords =
        '${loc.latitude.toStringAsFixed(6)}, ${loc.longitude.toStringAsFixed(6)}';
    setState(() {
      _lastCoords = coords;
      _lastSentAt = DateTime.now();
    });

    _showShareOptions(coords, loc.latitude, loc.longitude);
  }

  void _showShareOptions(String coords, double lat, double lng) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ShareSheet(
        coords: coords,
        latitude: lat,
        longitude: lng,
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderSection(),
          const SizedBox(height: 40),
          _SOSButton(
            isFetching: _isFetching,
            pulseAnimation: _pulseAnimation,
            onPressed: _handleSOS,
          ),
          const SizedBox(height: 32),
          _QuickCallRow(),
          if (_lastCoords != null) ...[
            const SizedBox(height: 24),
            _LastSentCard(
              coords: _lastCoords!,
              sentAt: _lastSentAt!,
            ),
          ],
          const SizedBox(height: 32),
          _EmergencyNumbers(),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.health_and_safety, size: 48, color: Colors.red),
        const SizedBox(height: 12),
        Text(
          'Acil Durum',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'SOS butonuna basın — GPS koordinatlarınız anında paylaşılır.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SOSButton extends StatelessWidget {
  final bool isFetching;
  final Animation<double> pulseAnimation;
  final VoidCallback onPressed;

  const _SOSButton({
    required this.isFetching,
    required this.pulseAnimation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: pulseAnimation,
        child: GestureDetector(
          onTap: isFetching ? null : onPressed,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFetching ? Colors.red.shade300 : Colors.red,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: isFetching
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : const Center(
                    child: Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _QuickCallRow extends StatelessWidget {
  Future<void> _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickCallButton(
            label: 'Polis',
            number: '155',
            icon: Icons.local_police,
            color: Colors.blue,
            onTap: () => _call('155'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickCallButton(
            label: 'Ambulans',
            number: '112',
            icon: Icons.medical_services,
            color: Colors.red,
            onTap: () => _call('112'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickCallButton(
            label: 'Turizm',
            number: '170',
            icon: Icons.support_agent,
            color: Colors.green,
            onTap: () => _call('170'),
          ),
        ),
      ],
    );
  }
}

class _QuickCallButton extends StatelessWidget {
  final String label;
  final String number;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickCallButton({
    required this.label,
    required this.number,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label,
                style:
                    TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            Text(number,
                style: TextStyle(
                    color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _LastSentCard extends StatelessWidget {
  final String coords;
  final DateTime sentAt;

  const _LastSentCard({required this.coords, required this.sentAt});

  @override
  Widget build(BuildContext context) {
    final time =
        '${sentAt.hour.toString().padLeft(2, '0')}:${sentAt.minute.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Son konum paylaşımı',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.green)),
                Text(coords,
                    style: const TextStyle(fontSize: 12, color: Colors.black87)),
                Text('Saat $time',
                    style:
                        const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyNumbers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final numbers = [
      ('İtfaiye', '110'),
      ('Jandarma', '156'),
      ('Sahil Güvenlik', '158'),
      ('ALO Turizm Danışma', '170'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Acil Numaralar',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...numbers.map((n) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(n.$1,
                          style: const TextStyle(fontSize: 13)),
                      Text(n.$2,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _ShareSheet extends StatelessWidget {
  final String coords;
  final double latitude;
  final double longitude;

  const _ShareSheet({
    required this.coords,
    required this.latitude,
    required this.longitude,
  });

  Future<void> _sendSMS(String coords) async {
    final msg = Uri.encodeComponent(
        'ACİL YARDIM: Konumum: $coords — Google Maps: https://maps.google.com/?q=$latitude,$longitude');
    final uri = Uri.parse('sms:?body=$msg');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openMaps() async {
    final uri = Uri.parse('https://maps.google.com/?q=$latitude,$longitude');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareText(BuildContext context) async {
    await Share.share(
      'ACİL YARDIM GEREKİYOR!\n'
      'Konum: $coords\n'
      'Harita: https://maps.google.com/?q=$latitude,$longitude',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Konum nasıl paylaşılsın?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            coords,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _ShareOption(
            icon: Icons.sms,
            color: Colors.green,
            label: 'SMS ile Gönder',
            onTap: () {
              Navigator.pop(context);
              _sendSMS(coords);
            },
          ),
          const SizedBox(height: 12),
          _ShareOption(
            icon: Icons.share,
            color: Colors.blue,
            label: 'Paylaş (WhatsApp, vb.)',
            onTap: () {
              Navigator.pop(context);
              _shareText(context);
            },
          ),
          const SizedBox(height: 12),
          _ShareOption(
            icon: Icons.map,
            color: Colors.orange,
            label: 'Google Maps\'te Aç',
            onTap: () {
              Navigator.pop(context);
              _openMaps();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(label,
                style:
                    TextStyle(fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}
