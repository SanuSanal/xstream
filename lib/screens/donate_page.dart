import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_donation_buttons/donationButtons/ko-fiButton.dart';
import 'package:flutter_donation_buttons/donationButtons/paypalButton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({super.key});

  @override
  DonatePageState createState() => DonatePageState();
}

class DonatePageState extends State<DonatePage> {
  bool _showDialog = true;

  @override
  void initState() {
    super.initState();

    _checkIfShowDialog();
  }

  @override
  Widget build(BuildContext context) {
    return _showDialog
        ? Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.99,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 8.0,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Like the app?',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    _showDialog = false;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Your support helps us improve and bring more features to the app. Thank you for considering!',
                            style: TextStyle(
                                fontSize: 14.0, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 16.0),
                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: KofiButton(
                                  kofiName: "sanalm",
                                  text: "Buy me a ko-fi",
                                  kofiColor: KofiColor.Orange,
                                  style: ButtonStyle(
                                    shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
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
                                    shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
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
                    ),
                  ),
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  Future<void> _checkIfShowDialog() async {
    final prefs = await SharedPreferences.getInstance();
    var lastShown = prefs.getString("lastShown");

    if (lastShown == null) {
      lastShown = DateTime.now().toString();
      prefs.setString("lastShown", lastShown);
    } else {
      final lastShownDate = DateTime.parse(lastShown);
      final now = DateTime.now();
      final difference = now.difference(lastShownDate).inDays;
      if (difference >= 7) {
        prefs.setString("lastShown", now.toString());
        setState(() {
          _showDialog = true;
        });
      }
    }
  }
}
