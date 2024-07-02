import 'dart:async';
import 'dart:math';

import 'package:example/debug_information.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Draggable;
import 'package:physik/physik.dart';

class BubblesExample extends FlameGame {
  @override
  Color backgroundColor() => const Color.fromARGB(255, 172, 172, 172);

  @override
  Future<void>? onLoad() {
    final solver = BubbleSolver();
    if (kDebugMode) {
      add(DebugInformation(solver: solver));
    }
    add(solver);

    return null;
  }
}

class BubbleSolver extends PositionComponent
    with PhysicsSolver, HasGameReference<BubblesExample> {
  BubbleSolver() {
    gravity.setFrom(baseGravity);
  }

  @override
  FutureOr<void>? onLoad() {
    add(
      TimerComponent(
        period: 1,
        onTick: () {
          if (particles.length < 20) {
            add(
              Bubble(
                position: Vector2.random()..multiply(game.size / 2),
                radius: Random().nextInt(10) + 10,
                color: const Color(0xFFFF0000),
              ),
            );
          }
        },
        repeat: true,
      ),
    );
    return super.onLoad();
  }

  int addBubble() {
    final index = particles.length;
    add(
      Bubble(
        position: Vector2.random()..multiply(game.size / 2),
        radius: Random().nextInt(10) + 10,
        color: const Color(0xFFFF0000),
      ),
    );
    return index + 1;
  }

  void updateBubble(int index, double radius) {
    (particles[index] as Bubble).radius = radius;
  }

  @override
  void applyGravity(int particleIndex) {
    final particle = particles[particleIndex];

    final direction = (game.size / 2 - particle.position).normalized();

    particle.forces.add(direction..multiply(gravity));
  }

  @override
  void apply(double dt, int particleIndex) {}

  @override
  void solve(double dt, int particleIndex) {
    solveRectangleConstraints(particleIndex);
    solveCollisions(particleIndex);
  }

  void solveRectangleConstraints(int particleIndex) {
    final particle = particles[particleIndex];

    // Define the rectangle boundaries
    const rectX = 0.0;
    const rectY = 0.0;
    final rectWidth = game.size.x;
    final rectHeight = game.size.y;

    // Calculate the half-size of the particle
    final particleRadiusX = particle.size.x / 2;
    final particleRadiusY = particle.size.y / 2;

    // Ensure the particle's position stays within the rectangle bounds
    if (particle.position.x - particleRadiusX < rectX) {
      particle.position.x = rectX + particleRadiusX;
    } else if (particle.position.x + particleRadiusX > rectX + rectWidth) {
      particle.position.x = rectX + rectWidth - particleRadiusX;
    }

    if (particle.position.y - particleRadiusY < rectY) {
      particle.position.y = rectY + particleRadiusY;
    } else if (particle.position.y + particleRadiusY > rectY + rectHeight) {
      particle.position.y = rectY + rectHeight - particleRadiusY;
    }
  }

  void solveCollisions(int particleIndex) {
    final particle1 = particles[particleIndex];
    for (var j = particleIndex + 1; j < particles.length; j++) {
      final particle2 = particles[j];

      final collisionAxis = particle1.position - particle2.position;
      final distance = collisionAxis.length;
      final minDistance = particle1.size.x / 2 + particle2.size.x / 2;

      if (distance < minDistance) {
        final penetration = minDistance - distance;
        final normal = collisionAxis
          ..scale(1.0 / distance)
          ..scale(0.5 * penetration);

        if (particle1.isMoving) {
          particle1.position.add(normal);
        }
        if (particle2.isMoving) {
          particle2.position.sub(normal);
        }
      }
    }
  }

  @override
  void update(double dt) {
    gravity.lerp(baseGravity, dt);
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, game.size.x, game.size.y), Paint());
    super.render(canvas);
  }

  static Vector2 baseGravity = Vector2(1500, 1500);
}

class Bubble extends PositionComponent with Particle, HasPaint {
  Bubble({
    required double radius,
    required Color color,
    super.position,
  }) : super(size: Vector2.all(radius * 2), anchor: Anchor.center) {
    paint.color = color;
  }

  double get radius => size.x / 2;
  set radius(double radius) => size.setFrom(Vector2.all(radius * 2));

  @override
  void render(Canvas canvas) {
    final center = size / 2;
    canvas.drawCircle(center.toOffset(), center.x, paint);
    super.render(canvas);
  }
}

void main() {
  runApp(GameWidget(game: BubblesExample()));
}
