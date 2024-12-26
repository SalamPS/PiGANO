import 'dart:async';

import 'package:flutter/material.dart';
import 'package:egano/src/background/particle.dart';
import 'package:egano/src/background/particles_animation.dart';
import 'package:egano/src/egano/input.dart';

class EganoWelcome extends StatefulWidget {
  const EganoWelcome({super.key});

  @override
  State<EganoWelcome> createState() => _EganoWelcomeState();
}

class _EganoWelcomeState extends State<EganoWelcome> {
  late List<Particle> particles;

  @override
  void initState() {
    super.initState();
    particles = [];
    for (int i = 0; i < 20; i++) {
      particles.add(Particle(width: 600, height: 701));
    }
    update();
  }
  update() {
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted) {
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255,29,36,55),
      body: CustomPaint(
        painter: ParticlesPainter(particles: particles, opacity: 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text.rich(
                      style: TextStyle(color: Colors.white),
                      TextSpan(
                        style: TextStyle(fontSize: 28),
                        children: [
                          TextSpan(
                            text: 'EGANO',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ' | Kejarkom K1',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        children: [
                          Text(
                            'Instant Image Encryptor and Decryptor\nusing Caesar and LSB method',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  MaterialButton(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    color: const Color(0xFF0f6252),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EganoInput())
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.key_rounded, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Coba sekarang !', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}