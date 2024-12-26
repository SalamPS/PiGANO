import 'dart:async';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:egano/src/background/particle.dart';
import 'package:egano/src/background/particles_animation.dart';
import 'package:egano/src/egano/result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class EganoInput extends StatefulWidget {
  const EganoInput({super.key});

  @override
  _EganoInputState createState() => _EganoInputState();
}

class _EganoInputState extends State<EganoInput> {
  late List<Particle> particles;
  final formKey = GlobalKey<FormState>();
  File? image;
  String privateKey = '';

  @override
  void initState() {
    particles = [];
    for (int i = 0; i < 20; i++) {
      particles.add(Particle(width: 600, height: 701));
    }
    update();
    super.initState();
    _requestPermissions();
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

  Future<void> _requestPermissions() async {
    PermissionStatus photoPermission = await Permission.photos.status;
    if (photoPermission.isGranted) {
      // Izin diberikan
    } else {
      photoPermission = await Permission.photos.request();
      PermissionStatus last = await Permission.photos.status;
      if (last.isGranted) {
        // Izin diberikan
      } else {
        // Izin ditolak
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to save images.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future pickImage(source) async {
    final image = await ImagePicker().pickImage(source: source == "gallery" ? ImageSource.gallery : ImageSource.camera);
    if (image == null) return;
    final imageTemp = File(image.path);
    setState(() => this.image = imageTemp);
  }

  void eganoCrypt (method, privateMessage) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EganoResult(
        image: image!,
        privateMessage: privateMessage,
        privateKey: int.parse(privateKey),
        method: method,
        ),
      ),
    );
  }

  void eganoStart (method) {
    if (!(
        privateKey.isNotEmpty && 
        int.tryParse(privateKey) != null && 
        int.parse(privateKey) > 0 &&
        int.parse(privateKey) < 10000000
      )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid required number !', style: TextStyle(color: Colors.black87)),
          backgroundColor: Color.fromARGB(255, 248, 181, 198),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide any image first !', style: TextStyle(color: Colors.black87)),
          backgroundColor: Color.fromARGB(255, 248, 181, 198),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (method == "Encrypt") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String privateMessage = '';
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 39, 48, 71),
            title: const Text('Private Message', style: TextStyle(color: Colors.white70, fontSize: 18)),
            content: TextField(
              onChanged: (value) {
                privateMessage = value;
              },
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF1D2437),
                hintText: 'Enter your message',
                hintStyle: TextStyle(color: Colors.white24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              ),
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Encrypt', style: TextStyle(color: Colors.white70)),
                onPressed: () {
                  if (privateMessage.isNotEmpty) {
                    eganoCrypt(method, privateMessage);
                  }
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter at least 1 character !', style: TextStyle(color: Colors.black87)),
                        backgroundColor: Color.fromARGB(255, 248, 181, 198),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    }
    else {
      eganoCrypt(method, "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D2437),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 29, 36, 55),
        title: const Center(
          child: Text.rich(
            TextSpan(
            style: TextStyle(color: Colors.white),
              children: [
                TextSpan(
                  text: 'EGANO',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' | Secure',
                ),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EganoInput()),
            );
          },
        ),
      ),
      body: CustomPaint(
        painter: ParticlesPainter(particles: particles, opacity: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: Center( 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                        child: Column(
                          children: [
                            
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: image == null ? const Color.fromARGB(82, 26, 155, 149) : const Color.fromARGB(174, 26, 155, 149),
                                  style: BorderStyle.solid,
                                  width: image == null ? 2.0 : 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  image == null
                                  ? const SizedBox(
                                    height: 240,
                                    child: Icon(
                                      Icons.image,
                                      size: 120,
                                      color: Colors.white30,
                                    ),
                                  )
                                  : Image.file(
                                    image!,
                                    height: 240, // Set the maximum height
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 4),
                            image != null ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
                              child: Row(
                                children: [
                                  Text(
                                      image != null ? "...${image!.path.substring(image!.path.length - 30)}" : "",
                                    style: const TextStyle(color: Colors.white70)
                                  ),
                                ],
                              )
                            ) : const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: MaterialButton(
                                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    color: const Color(0xFF0f6252),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            color: const Color(0xFF1D2437),
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  leading: const Icon(Icons.image, color: Colors.white70),
                                                  title: const Text('Pick Image from Gallery', style: TextStyle(color: Colors.white70)),
                                                  onTap: () {
                                                    pickImage("gallery");
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                ListTile(
                                                  leading: const Icon(Icons.camera, color: Colors.white70),
                                                  title: const Text('Pick Image from Camera', style: TextStyle(color: Colors.white70)),
                                                  onTap: () {
                                                    pickImage("camera");
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.cloud_upload_rounded, color: Colors.white70),
                                        const SizedBox(width: 8),
                                        Text(
                                          image == null ? "Upload Image" : "Re-upload Image",
                                          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ),
                    ],
                  ),
                ),
              ),
            ),
              Container(
              color: const Color(0xFF1D2437),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) { 
                        setState(() => privateKey = value); 
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white10,
                        hintText: 'Enter 1-8 digits of number',
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                      ),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: MaterialButton(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            color: image == null || privateKey.isEmpty ? const Color.fromARGB(118, 15, 98, 81) : const Color(0xFF0f6252),
                            onPressed: () {
                              eganoStart("Encrypt");
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.vpn_key, color: image == null || privateKey.isEmpty ? Colors.white38 : Colors.white70),
                                const SizedBox(width: 8),
                                Text(
                                  "Encrypt",
                                  style: TextStyle(color: image == null || privateKey.isEmpty ? Colors.white38 : Colors.white70, fontWeight: FontWeight.bold)
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MaterialButton(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            color: image == null || privateKey.isEmpty ? const Color.fromARGB(118, 15, 98, 81) : const Color(0xFF0f6252),
                            onPressed: () {
                              eganoStart("Decrypt");
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.key_off_rounded, color: image == null || privateKey.isEmpty ? Colors.white38 : Colors.white70),
                                const SizedBox(width: 8),
                                Text(
                                  "Decrypt",
                                  style: TextStyle(color: image == null || privateKey.isEmpty ? Colors.white38 : Colors.white70, fontWeight: FontWeight.bold)
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}