import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/localization_extension.dart';

/// About page in the classic style: version, phone, email, designer,
/// then a row of contact icons.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String _phoneDisplay = '+93 782 449 546';
  static const String _phoneLink = 'tel:+93782449546';
  static const String _email = 'haidarzada987@gmail.com';

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('aboutUs'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/icon.png', width: 92, height: 92),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              context.tr('appName'),
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 22),
          _row(context, context.tr('versionLabel'), '1.2.1'),
          _row(context, context.tr('phoneLabel'), _phoneDisplay),
          _row(context, context.tr('emailLabel'), _email),
          _row(context, context.tr('designedBy'), 'Noorullah Haidari'),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _social(
                context,
                icon: Icons.camera_alt,
                color: const Color(0xFFC13584),
                onTap: () => _open('https://www.instagram.com/noo_rullha'),
              ),
              _social(
                context,
                icon: Icons.facebook,
                color: const Color(0xFF1877F2),
                onTap: () =>
                    _open('https://www.facebook.com/nwrallh.hydry.70341'),
              ),
              _social(
                context,
                icon: Icons.phone,
                color: const Color(0xFF2E7D32),
                onTap: () => _open(_phoneLink),
              ),
              _social(
                context,
                icon: Icons.email,
                color: const Color(0xFFD44638),
                onTap: () => _open('mailto:$_email'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ListTile(
            leading: const Icon(Icons.code_outlined),
            title: const Text('GitHub'),
            subtitle: const Text('github.com/haidarzada987-tech'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _open('https://github.com/haidarzada987-tech'),
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('LinkedIn'),
            subtitle: const Text('linkedin.com/in/haidar-zada'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () =>
                _open('https://www.linkedin.com/in/haidar-zada-44863142b'),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.65),
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _social(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 27),
      ),
    );
  }
}
