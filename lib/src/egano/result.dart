// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:egano/src/utils/notification_utils.dart';
import 'package:egano/src/utils/preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:egano/src/background/particle.dart';
import 'package:egano/src/background/particles_animation.dart';
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

  String? _mse;
  String? _psnr;
  String? _cipherMessage;
  String? _decodedMessage;
  
  File? _encodedImage;

  @override
  void initState() {
    super.initState();
    particles = [];
    for (int i = 0; i < 20; i++) {
      particles.add(Particle(width: 600, height: 701));
    }
    update();
    _setupFetches();
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

  Future <void> _setupFetches () async {
    String configUrl = await getData("apiUrl");
    _startFetching(configUrl);
  }

  Future<File> _generateFile () async {
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final timestamp = DateFormat('yyyy-MM-dd-HH-mm').format(DateTime.now());
    final extension = widget.image.path.split('.').last;
    final path = '${directory.path}/encrypted-$timestamp.$extension';
    return File(path);
  }

  void _startFetching(String baseUrl) async {
    String result = '';
    if (widget.method == 'Encrypt') {
      result = await _encodeImage(baseUrl);
    } else if (widget.method == "Decrypt") {
      result = await _decodeImage(baseUrl);
    }
    
    if (mounted && result.isNotEmpty) {
      if (result.contains("encrypted") || result.contains("decrypted")) {
        NotificationUtils.showSuccessNotification(context, result);
      } else {
        NotificationUtils.showErrorNotification(context, result);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<dynamic> _encodeImage(String baseUrl) async {
    try {
      final url = Uri.parse('$baseUrl/encode');
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('image', widget.image.path))
        ..fields['message'] = widget.privateMessage
        ..fields['key'] = widget.privateKey.toString();

      final response = await request.send();
      
      if (response.statusCode == 200 && mounted) {
        final responseData = await http.Response.fromStream(response);
        final Map<String, dynamic> responseJson = json.decode(responseData.body);

        final mseRes = responseJson['mse'];
        final psnrRes = responseJson['psnr'];
        final filename = responseJson['filename'];
        final cipherMessage = responseJson['ciphertext'];

        final downloadUrl = Uri.parse('$baseUrl/download');
        final downloadRequest = await http.post(
          downloadUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'filename': filename}),
        );

        if (downloadRequest.statusCode == 200) {
          final file = await _generateFile();
          await file.writeAsBytes(downloadRequest.bodyBytes);
          setState(() {
            _mse = mseRes!.toStringAsFixed(6);
            _psnr = psnrRes!.toStringAsFixed(6);
            _encodedImage = file;
            _cipherMessage = cipherMessage;
            _isSuccess = true;
          });
          return "Your message has been encrypted successfully and saved to your gallery.";
        } else {
            final errorMessage = jsonDecode(downloadRequest.body)['error'] ?? 'Unknown error';
            return "Failed to download your new image: $errorMessage";
        }
      } else {
        final errorMessage = response.reasonPhrase ?? 'Unknown error';
        return "Failed to connect: $errorMessage";
      }
    } catch (e) {
      return "Failed: $e";
    }
  }

  Future<dynamic> _decodeImage (String baseUrl) async {
    try {
      final url = Uri.parse('$baseUrl/decode');
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('file', widget.image.path))
        ..fields['key'] = widget.privateKey.toString();

      final response = await request.send();

      if (response.statusCode == 200 && mounted) {
        final responseData = await http.Response.fromStream(response);
        final decodedText = jsonDecode(responseData.body)['plain_text'];
        // Cek apakah sesuai dengan format yang kita inginkan
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
        final errorMessage = response.reasonPhrase ?? 'Unknown error';
        print(errorMessage);
        return "Failed to connect: $errorMessage";
      }
    } catch (e) {
      print(e);
      return "Failed: $e";
    }
  }

  Widget encryptionResult(String title, String subtitle, int limit) {
    if (!_isLoading && _isSuccess) {
      String sub = limit > 0 
        ? subtitle.length > limit ? '${subtitle.substring(0, limit)}...' : subtitle
        : subtitle;

      return Text.rich(
        TextSpan(
          style: const TextStyle(color: Colors.white70, fontSize: 16),
          children: [
            TextSpan(
              text: title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
                text: sub,
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
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
                text: 'PiGANO',
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
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            if (widget.method == "Encrypt" && !_isLoading && _isSuccess) ...[
                              encryptionResult('MSE\t\t\t: ', _mse ?? 'N/A', 30),
                              encryptionResult('PSNR\t: ', _psnr ?? 'N/A', 30),
                              encryptionResult('CPT\t\t\t\t: ', _cipherMessage ?? 'N/A', 30),
                              encryptionResult("TXT\t\t\t\t: ", widget.privateMessage, 0),
                            ] else if (widget.method == "Decrypt" && !_isLoading && _isSuccess) ...[
                              encryptionResult("DECRYPTED: ", _decodedMessage != null ? _decodedMessage! : 'N/A', 0),
                            ],
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
                            try {
                              final file = await _generateFile();
                              await file.writeAsBytes(await _encodedImage!.readAsBytes());
                              NotificationUtils.showSuccessNotification(context, 'Image saved to ${file.path}');
                            } catch (e) {
                              NotificationUtils.showErrorNotification(context, 'Failed to save image: $e');
                            }
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