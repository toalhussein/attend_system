import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UserNameAndLocation extends StatelessWidget {
  const UserNameAndLocation({
    super.key,
    required this.userName,
    required this.lat,
    required this.lang,
    required this.fontColor,
    this.fontSize = 16,
    required this.buttonColor,
  });
  final Color fontColor;
  final String userName;
  final double lat;
  final double lang;
  final double? fontSize;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            userName,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: fontColor,
            ),
          ),
        ),
        IconButton(
          onPressed: () async {
            Uri url = Uri.parse('http://maps.google.com/?q=$lat,$lang');
            await launchUrl(url);
          },
          icon: Icon(
            Icons.location_on,
            color: buttonColor,
            size: 28,
          ),
        ),
      ],
    );
  }
}
