import 'dart:math';

import 'package:flutter/material.dart';
import 'package:egano/src/background/particle.dart';

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final int opacity;

  ParticlesPainter({required this.particles, this.opacity = 255});

  //eucledian distance formula
  double dist(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < particles.length; i++) {
      var particle = particles[i];

      if (particle.x < 0 || particle.x > size.width) {
        particles[i].xSpeed *= -1;
      }

      if (particle.y < 0 || particle.y > size.height) {
        particles[i].ySpeed *= -1;
      }

      particles[i].x += particle.xSpeed;
      particles[i].y += particle.ySpeed;

      for (var j = i + 1; j < particles.length; j++) {
        var nxtParticle = particles[j];

        var distance =
            dist(particle.x, particle.y, nxtParticle.x, nxtParticle.y);

        if (distance < 85) {
          var linePaint = Paint()
            ..color = Color.fromARGB(opacity, 26, 155, 149)
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 1;

          Offset point1 = Offset(particle.x, particle.y);
          Offset point2 = Offset(nxtParticle.x, nxtParticle.y);

          canvas.drawLine(point1, point2, linePaint);
        }
      }

      var paint = Paint()
        ..color = Color.fromARGB(opacity, 26, 155, 149)
        ..style = PaintingStyle.fill;

      var circlePosition = Offset(particle.x, particle.y);

      canvas.drawCircle(circlePosition, particle.r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}