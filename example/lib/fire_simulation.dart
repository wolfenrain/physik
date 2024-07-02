import 'dart:math' as math;

import 'package:example/debug_information.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:physik/physik.dart';

const particleSize = 10.0;
const particleRadius = particleSize / 2;

class FireSimulation extends FlameGame {
  @override
  Color backgroundColor() => debugPaint.color;

  @override
  Future<void>? onLoad() {
    final solver = FireSimulationSolver();
    add(DebugInformation(solver: solver));
    add(solver);

    for (var y = 0; y < 8; y++) {
      for (var x = 0; x < size.x / particleSize; x++) {
        solver.add(
          FireParticle(
            position: Vector2(x * particleSize, size.y - (y * particleSize)),
            temperature: y < 1 ? 100 : 0,
          ),
        );
      }
    }
    return null;
  }
}

class FireSimulationSolver extends Component with PhysicsSolver, HasGameRef {
  @override
  void apply(double dt, int particleIndex) {
    applyTemperature(particleIndex);
  }

  void applyTemperature(int particleIndex) {
    final particle = particles[particleIndex] as FireParticle;
    final points = [
      Vector2(gameRef.size.x * 0.25, gameRef.size.y - particleSize),
      Vector2(gameRef.size.x * 0.75, gameRef.size.y - particleSize),
    ];
    for (final point in points) {
      if (inRadius(particle, point, particleSize * 4)) {
        particle.temperature += 30;
      }
    }
  }

  bool inRadius(Particle particle, Vector2 center, double radius) {
    final distance = particle.position - center;
    return distance.length2 < radius * radius;
  }

  @override
  void applyGravity(int particleIndex) {
    final particle = particles[particleIndex] as FireParticle;

    particle.forces.add(gravity);

    final temperature = particle.temperature / 100;
    final upwardsForce = convert(
      temperature,
      0,
      1,
      0,
      gravity.y * 1.5,
    );
    particle.forces.y -= upwardsForce;
  }

  double convert(
    double oldValue,
    double oldMin,
    double oldMax,
    double newMin,
    double newMax,
  ) {
    return (oldValue - oldMin) * (newMax - newMin) / (oldMax - oldMin) + newMin;
  }

  @override
  void solve(double dt, int particleIndex) {
    solveCollisions(particleIndex);
    solveRectangleConstraint(particleIndex);
  }

  void solveRectangleConstraint(int particleIndex) {
    final particle = particles[particleIndex];
    final radius = Vector2.all(particle.size.x / 2);
    particle.position.clamp(radius, gameRef.size - radius);
  }

  void solveCollisions(int particleIndex) {
    final particle1 = particles[particleIndex] as FireParticle;

    for (var j = particleIndex + 1; j < particles.length; j++) {
      final particle2 = particles[j] as FireParticle;

      final collisionAxisX = particle1.position.x - particle2.position.x;
      final collisionAxisY = particle1.position.y - particle2.position.y;
      final distance = math.sqrt(
        collisionAxisX * collisionAxisX + collisionAxisY * collisionAxisY,
      );
      // final collisionAxis = particle1.position - particle2.position;
      // final distance = collisionAxis.length;

      final minDistance = particle1.size.x / 2 + particle2.size.x / 2;

      if (distance < minDistance) {
        particle1.onCollide(particle2);

        final delta = minDistance - distance;
        final normalX = (collisionAxisX / distance) * 0.5 * delta;
        final normalY = (collisionAxisY / distance) * 0.5 * delta;
        // final normal = collisionAxis
        //   ..scale(1.0 / distance)
        //   ..scale(0.5 * delta);

        // if (particle1.isMoving) {
        //   particle1.position.add(normal);
        // }
        // if (particle2.isMoving) {
        //   particle2.position.sub(normal);
        // }
        if (particle1.isMoving) {
          particle1.position
            ..x += normalX
            ..y += normalY;
        }
        if (particle2.isMoving) {
          particle2.position
            ..x -= normalX
            ..y -= normalY;
        }
      }
    }
  }
}

class FireParticle extends PositionComponent with Particle, HasPaint {
  FireParticle({
    super.position,
    required double temperature,
  })  : _temperature = temperature,
        assert(
          temperature >= 0 && temperature <= 100,
          'Temperature must be between 0 and 100',
        ),
        super(size: Vector2.all(particleSize), anchor: Anchor.center) {
    paint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 10);
  }

  double _temperature;

  double get temperature => _temperature;
  set temperature(double value) {
    _temperature = value.clamp(0, 100);
  }

  void onCollide(FireParticle particle) {
    final temperatureChange =
        (particle.temperature - temperature) / (particle.mass + mass);

    temperature += temperatureChange;
    particle.temperature -= temperatureChange;
  }

  @override
  void update(double dt) {
    paint.color = getTemperatureColor();

    temperature -= 45 * dt;

    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final center = size / 2;
    canvas.drawCircle(center.toOffset(), center.x, paint);
    super.render(canvas);
  }

  Color getTemperatureColor() {
    final colorStops = [
      const Color(0xFF000000),
      const Color(0xFFFF0000),
      const Color(0xFFFFA500),
      const Color(0xFFFFFFFF),
    ];

    const min = 0;
    const max = 100;
    if (temperature < min) return colorStops.first;
    if (temperature > max) return colorStops.last;
    final length = colorStops.length;

    const range = max - min;
    var weight = (temperature - min) / range;
    final index = math.max((weight * (length - 1)).ceil(), 1);

    final minColor = colorStops[index - 1];
    final maxColor = colorStops[index];

    weight = weight * (length - 1) - (index - 1);

    return Color.fromARGB(
      255,
      (weight * maxColor.red + (1 - weight) * minColor.red).floor(),
      (weight * maxColor.green + (1 - weight) * minColor.green).floor(),
      (weight * maxColor.blue + (1 - weight) * minColor.blue).floor(),
    );
  }
}

void main() {
  runApp(GameWidget(game: FireSimulation()));
}
