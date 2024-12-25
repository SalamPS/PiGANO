import 'package:flutter/material.dart';
import 'package:egano/src/index.dart';

void main() {
  runApp(const Egano());
}

class Egano extends StatelessWidget {
  const Egano({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EGANO | Kejarkom K1',
      theme: ThemeData(
        fontFamily: 'Tektur',
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color.fromARGB(0,29,36,55),
        primaryColor: const Color.fromARGB(255,29,36,55),
        splashColor: const Color.fromARGB(255,29,36,55),
        primaryIconTheme: const IconThemeData(color: Colors.white),
      ),
      home: const EganoWelcome(),
    );
  }
}