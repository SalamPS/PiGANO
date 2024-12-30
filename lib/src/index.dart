import 'dart:async';

import 'package:egano/src/utils/notification_utils.dart';
import 'package:egano/src/utils/preferences.dart';
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
  final TextEditingController _apiUrlCtr = TextEditingController();
  final TextEditingController _sizeLimitCtr = TextEditingController();

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

  void configAPI () async {
    String configUrl = await getData("apiUrl");
    String sizeLimit = await getData("sizeLimit");

    if (configUrl.isNotEmpty) {
      _apiUrlCtr.text = configUrl;
      _sizeLimitCtr.text = sizeLimit;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 39, 48, 71),
          title: const Text('Custom PiGANO API', style: TextStyle(color: Colors.white70, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _apiUrlCtr,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF1D2437),
                  hintText: 'Enter your API\'s root url',
                  hintStyle: TextStyle(color: Colors.white24),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                ),
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _sizeLimitCtr,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF1D2437),
                  hintText: 'Upload size limit (MB)',
                  hintStyle: TextStyle(color: Colors.white24),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                ),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Discard', style: TextStyle(color: Colors.white70)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save', style: TextStyle(color: Colors.white70)),
              onPressed: () {
                if (_apiUrlCtr.text.isEmpty || !RegExp(r'^(https?|http):\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}').hasMatch(_apiUrlCtr.text)) {
                  NotificationUtils.showErrorNotification(context, 'Please input valid url');
                }
                else if (_sizeLimitCtr.text.isEmpty || double.tryParse(_sizeLimitCtr.text) == null) {
                  NotificationUtils.showErrorNotification(context, 'Please input valid number');
                }
                else {
                  saveData("apiUrl", _apiUrlCtr.text);
                  if (!_apiUrlCtr.text.contains("py.salamp.id")) {
                    saveData("sizeLimit", _sizeLimitCtr.text);
                  }
                  else {
                    saveData("sizeLimit", "1");
                  }
                  NotificationUtils.showSuccessNotification(context, 'Successfully updating API config');
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
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
                            text: 'PiGANO',
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
                            'Instant Image Encryptor and Decryptor\nusing Caesar cipher and LSB method',
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
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
              child: Row(
                children: [
                  Expanded(child: 
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
                          Text('Try now !', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  MaterialButton(
                    minWidth: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    color: const Color(0xFF0f6252),
                    onPressed: () {
                      configAPI();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.settings_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}