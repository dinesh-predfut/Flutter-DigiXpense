import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Support screen with Email Support and Contact (Call) Support cards.
///
/// Add this dependency to pubspec.yaml:
///   url_launcher: ^6.3.0
class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  static const String supportEmail = 'support@digidelight.ai';
  static const String supportPhone = '+914040151597'; // no spaces/dashes for tel: URI
  static const String supportPhoneDisplay = '+91 40 4015 1597';

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        'subject': 'Support Request',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showError(context, 'Could not open email app.');
    }
  }

  Future<void> _launchDialer(BuildContext context) async {
    final Uri telUri = Uri(scheme: 'tel', path: supportPhone);

    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      _showError(context, 'Could not open dialer.');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Need help? Reach out to us using any of the options below.',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Email Support Card
            _SupportCard(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: supportEmail,
              onTap: () => _launchEmail(context),
            ),
            const SizedBox(height: 12),

            // Contact / Call Support Card
            _SupportCard(
              icon: Icons.call_outlined,
              title: 'Contact Support',
              subtitle: supportPhoneDisplay,
              onTap: () => _launchDialer(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Icon(icon, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}