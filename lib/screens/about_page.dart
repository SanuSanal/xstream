import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_donation_buttons/donationButtons/ko-fiButton.dart';
import 'package:flutter_donation_buttons/donationButtons/paypalButton.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle =
        Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18);

    Uri contactUrl = Uri.parse('https://devlog-notes.web.app/#/contact');

    void lauchSupportPage() async {
      if (await canLaunchUrl(contactUrl)) {
        await launchUrl(contactUrl);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch the support page!'),
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('XStream'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎥 About XStream',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to XStream, the ultimate app for seamless video streaming! Whether you\'re a football fanatic or a movie lover, XStream lets you stream live from various sites, completely hassle-free.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Get Started:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Download the app, add your favorite streaming site, and start watching video contents instantly without the usual interruptions!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'What We Offer:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '- Customizable Streaming: Add your favorite streaming sites and stream contents without interruptions.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '- Ad and Popup Blocking: Enjoy a clean, smooth experience as XStream blocks unwanted ads, popups, and redirects that usually clutter your stream.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '- Multi-Category Support: XStream is compatible with any category. Configure the app for sports, entertainment, or any other streaming site you choose!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              '⚠️ Note:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'While XStream offers a smooth streaming experience, some streaming sites that you are linkely to use may not be secure. Use them with caution to avoid potential risks.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Support & Contributions:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: defaultTextStyle,
                children: [
                  const TextSpan(
                    text:
                        'We\'re constantly improving XStream to make your streaming experience even better. If you encounter any issues or have suggestions, please ',
                  ),
                  TextSpan(
                    text: 'reach out to us',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        lauchSupportPage();
                      },
                  ),
                  const TextSpan(
                    text: '. Your feedback is always appreciated!',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Developed with passion by Sanal.\n\nHappy Streaming! 🌟',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            const Text(
              'Like my work?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: KofiButton(
                        kofiName: "sanalm",
                        text: "Buy me a ko-fi",
                        kofiColor: KofiColor.Orange,
                        style: ButtonStyle(
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PayPalButton(
                        paypalButtonId: "HBGNBZL5VRMTY",
                        donationText: "Support Me!",
                        color: Colors.white10,
                        style: ButtonStyle(
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
