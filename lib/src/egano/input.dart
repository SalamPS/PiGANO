// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:egano/src/utils/notification_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:egano/src/background/particle.dart';
import 'package:egano/src/background/particles_animation.dart';
import 'package:egano/src/egano/result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class EganoInput extends StatefulWidget {
  const EganoInput({super.key});

  @override
  EganoInputState createState() => EganoInputState();
}

class EganoInputState extends State<EganoInput> {
  final int maxFileSize = 10;
  late List<Particle> particles;
  TextEditingController privateKeyCtr = TextEditingController();
  TextEditingController privateMessageCtr = TextEditingController();
  File? image;

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
  
  @override
  void dispose() {
    // Bersihkan semua controller
    privateKeyCtr.dispose();
    privateMessageCtr.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    PermissionStatus photoPermission = await Permission.photos.status;
    PermissionStatus storagePermission = await Permission.storage.status;

    if (!photoPermission.isGranted && !storagePermission.isGranted) {
      photoPermission = await Permission.photos.request();

      if (!photoPermission.isGranted) {
        storagePermission = await Permission.storage.request();

        if (!storagePermission.isGranted) {
          NotificationUtils.showErrorNotification(context, 'Storage permission is required to save images.');
        }
      }
    }
  }

  Future pickImage(source) async {
    final image = await ImagePicker().pickImage(source: source == "gallery" ? ImageSource.gallery : ImageSource.camera);
    if (image != null) {
      if (await image.length() > maxFileSize * 1024 * 1024) {
        NotificationUtils.showErrorNotification(context, 'Please provide an image with a size of less than ${maxFileSize}MB !');
      }
      else {
        setState(() {
          this.image = File(image.path);
        });
      }
    }
  }

  void eganoCrypt (method) {
    // Menyimpan data yang diperlukan sebelum membersihkan
    final imageToPass = image;
    final privateKeyToPass = privateKeyCtr.text;
    final privateMessageToPass = privateMessageCtr.text;

    // Membersihkan controller dan image
    privateKeyCtr.clear();
    privateMessageCtr.clear();
    image = null;

    // Navigasi ke halaman berikutnya
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EganoResult(
          image: imageToPass!,
          privateKey: int.parse(privateKeyToPass),
          privateMessage: privateMessageToPass,
          method: method,
        ),
      ),
    );
  }

  void eganoStart (method) {
    if (image == null) {
      NotificationUtils.showErrorNotification(context, 'Please provide any image first !');
      return;
    }

    if (!(
        privateKeyCtr.text.isNotEmpty && 
        int.tryParse(privateKeyCtr.text) != null && 
        int.parse(privateKeyCtr.text) > 0 &&
        int.parse(privateKeyCtr.text) < 10000000
      )) {
      NotificationUtils.showErrorNotification(context, 'Please enter valid required number !');
      return;
    }

    if (method == "Decrypt") {
      eganoCrypt(method);
    }
    else if (method == "Encrypt") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 39, 48, 71),
            title: const Text('Private Message', style: TextStyle(color: Colors.white70, fontSize: 18)),
            content: TextField(
              controller: privateMessageCtr,
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
                  if (privateMessageCtr.text.isNotEmpty) {
                    eganoCrypt(method);
                  }
                  else {
                    NotificationUtils.showErrorNotification(context, 'Please enter at least 1 character !');
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }
  
  Widget eganoOption (String method, IconData icon) {
    return Expanded(
      child: MaterialButton(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: image == null || privateKeyCtr.text.isEmpty ? const Color.fromARGB(118, 15, 98, 81) : const Color(0xFF0f6252),
        onPressed: () {
          eganoStart(method);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: image == null || privateKeyCtr.text.isEmpty ? Colors.white38 : Colors.white70),
            const SizedBox(width: 8),
            Text(
              method,
              style: TextStyle(color: image == null || privateKeyCtr.text.isEmpty ? Colors.white38 : Colors.white70, fontWeight: FontWeight.bold)
            ),
          ],
        ),
      ),
    );
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
                  text: 'PiGANO',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' | Secure',
                ),
              ],
            ),
          ),
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
                      controller: privateKeyCtr,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white10,
                        hintText: 'Enter 1-8 digits of privacy key',
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
                        eganoOption("Encrypt", Icons.vpn_key),
                        const SizedBox(width: 10),
                        eganoOption("Decrypt", Icons.key_off_rounded)
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