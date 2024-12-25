// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditPage extends StatelessWidget {
  final List<Map<String, String>> creators = [
    {'name': 'Salam', 'url': 'https://linkedin.com/salam-pararta'},
    {'name': 'Farhan', 'url': 'https://linkedin.com/farhan'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Page'),
      ),
      body: ListView.builder(
        itemCount: creators.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(creators[index]['name']!),
            onTap: () => _launchURL(creators[index]['url']!),
          );
        },
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(url as Uri)) {
      await launchUrl(url as Uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}