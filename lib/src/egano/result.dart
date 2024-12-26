// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:egano/src/background/particle.dart';
import 'package:egano/src/background/particles_animation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class EganoResult extends StatefulWidget {
  final File image;
  final String method;
  final String privateMessage;
  final int privateKey;

  const EganoResult({super.key, required this.image, required this.method, required this.privateKey, required this.privateMessage});

  @override
  EganoResultState createState() => EganoResultState();
}

class EganoResultState extends State<EganoResult> {
  late List<Particle> particles;
  final directory = Directory('/storage/emulated/0/Pictures/Egano');
  bool _isLoading = true;
  bool _isSuccess = false;

  File? _encodedImage;
  String? _decodedMessage;

  @override
  void initState() {
    super.initState();
    particles = [];
    for (int i = 0; i < 20; i++) {
      particles.add(Particle(width: 600, height: 701));
    }
    update();
    _startFetching();
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

  Future<void> _saveImage() async {
    try {
      final timestamp = DateFormat('HH-mm-dd-MM-yyyy').format(DateTime.now());
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final extension = _encodedImage!.path.split('.').last;
      final path = '${directory.path}/encrypted-$timestamp.$extension';
      final file = File(path);
      await file.writeAsBytes(await _encodedImage!.readAsBytes());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image saved to $path', style: const TextStyle(color: Colors.black87)),
          backgroundColor: const Color.fromARGB(255, 230, 250, 252),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save image: $e', style: const TextStyle(color: Colors.black87)),
          backgroundColor: const Color.fromARGB(255, 230, 250, 252),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _startFetching() async {
    final timestamp = DateFormat('HH-mm-dd-MM-yyyy').format(DateTime.now());
    String result = '';
    if (widget.method == 'Encrypt') {
      result = await _encodeImage(timestamp);
    } else {
      result = await _decodeImage(timestamp);
    }
    
    if (mounted) {
      if (result.contains("encrypted") || result.contains("decrypted")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result, style: const TextStyle(color: Colors.black87)),
            backgroundColor: const Color.fromARGB(255, 230, 250, 252),
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result, style: const TextStyle(color: Colors.black87)),
            backgroundColor: const Color.fromARGB(255, 248, 181, 198),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<dynamic> _encodeImage(timestamp) async {
    try {
      final url = Uri.parse('https://py.salamp.id/encode');
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('file', widget.image.path))
        ..fields['message'] = widget.privateMessage
        ..fields['key'] = widget.privateKey.toString();

      final response = await request.send();
      final extension = widget.image.path.split('.').last;
      
      if (response.statusCode == 200 && mounted) {
        final responseData = await http.Response.fromStream(response);
        final filePath = '${directory.path}/encoded-image-$timestamp.$extension';
        final file = File(filePath);
        await file.writeAsBytes(responseData.bodyBytes);

        setState(() {
          _encodedImage = file;
        });
        _isSuccess = true;
        return "Your message has been encrypted successfully and saved to your gallery.";
      } else {
        return "Failed because we could not connect to our encryptor server !";
      }
    } catch (e) {
      return "Failed to connect to the server. Please check your connection !";
    }
  }

  Future<dynamic> _decodeImage (timestamp) async {
    try {
      final url = Uri.parse('https://py.salamp.id/decode');
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('file', widget.image.path))
        ..fields['key'] = widget.privateKey.toString();

      final response = await request.send();

      if (response.statusCode == 200 && mounted) {
        final responseData = await http.Response.fromStream(response);
        final decodedText = jsonDecode(responseData.body)['plain_text'];
        if (RegExp(r'^[a-zA-Z\s,\.]+$').hasMatch(decodedText)) {
          setState(() {
              _decodedMessage = decodedText;
          });
          _isSuccess = true;
          return "Your picture has been decrypted successfully and copied to your clipboard.";
        } else {
           return "Failed to decrypt image. Please provide a picture that match your private key !";
        }
      } else {
         return "Failed because we could not connect to our decryptor server !";
      }
    } catch (e) {
       return "Failed to connect to the server. Please check your connection !";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D2437),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1D2437),
        title: Text.rich(
          TextSpan(
            style: const TextStyle(color: Colors.white),
            children: [
              const TextSpan(
                text: 'EGANO',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: widget.method == 'Encrypt' ? ' | Encryptor' : ' | Decryptor',
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
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
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          children: [
                            Container(
                              width: _isLoading ? 50 : double.infinity,
                              decoration: BoxDecoration(
                                border: _isLoading ? null : Border.all(
                                  color: Colors.white30,
                                  style: BorderStyle.solid,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _isLoading
                              ? const AspectRatio(
                                aspectRatio: 1,
                                child: CircularProgressIndicator(),
                              )
                              : _encodedImage != null 
                              ? SizedBox(
                                height: 240,
                                child: Image.file(_encodedImage!),
                              ) 
                              : SizedBox(
                                height: 240,
                                child: Image.file(widget.image),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(width: 5),
                                Expanded(child: 
                                  _isLoading || !_isSuccess
                                  ? const Text('', style: TextStyle(color: Colors.white70))
                                  : Text.rich(
                                    TextSpan(
                                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                                      children: [
                                        TextSpan(
                                          text: widget.method == 'Encrypt' ? 'ENCRYPTED: ' : 'DECRYPTED: ',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: _decodedMessage ?? widget.privateMessage,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: MaterialButton(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      color: !_isLoading && _isSuccess ? const Color(0xFF0f6252) : const Color.fromARGB(118, 15, 98, 81),
                      onPressed: () async {
                        if (!_isLoading && _isSuccess) {
                          if (widget.method == "Encrypt") {
                            _saveImage();
                          } else {
                            Clipboard.setData(ClipboardData(text: _decodedMessage!));
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.method == "Encrypt" ? Icons.save_rounded : Icons.copy_all_rounded,
                            color: !_isLoading && _isSuccess ? Colors.white70 : Colors.white38),
                          const SizedBox(width: 8),
                          Text(
                            widget.method == "Encrypt" ? "Save Encrypted Image" : "Copy Decrypted Text",
                            style: TextStyle(color: !_isLoading && _isSuccess ? Colors.white70 : Colors.white38, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  MaterialButton(
                    minWidth: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    color: !_isLoading ? const Color(0xFF0f6252) : const Color.fromARGB(118, 15, 98, 81) ,
                    onPressed: () async {
                      if (!_isLoading) {
                        Navigator.pop(context);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home_rounded,
                          color: !_isLoading ? Colors.white70 : Colors.white38),
                      ],
                    ),
                  ),
                ],
              )
            )
          ],
        ),
      )
    );
  }
}