import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Draggable;
import 'package:physik/physik.dart';

class PhysikExample extends FlameGame with HasDraggables {
  @override
  Color backgroundColor() => const Color.fromARGB(255, 172, 172, 172);

  @override
  Future<void>? onLoad() {
    add(
      CircleSolver(
        radius: 200,
      ),
    );

    add(FpsTextComponent());

    camera.followVector2(Vector2.zero());
    return null;
  }
}

class CircleSolver extends PositionComponent with PhysicsSolver, Draggable {
  CircleSolver({
    super.position,
    required double radius,
  }) : super(size: Vector2.all(radius * 2), anchor: Anchor.center) {
    gravity.setFrom(baseGravity);
  }

  static Vector2 baseGravity = Vector2(0, 1500);

  double get radius => size.x / 2;

  @override
  Future<void>? onLoad() {
    add(
      TimerComponent(
        period: 0.2,
        onTick: () {
          if (particles.length < 200) {
            add(
              CircleParticle(
                position: Vector2(size.x * 0.75, size.y * 0.25),
                radius: 10,
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

  @override
  void apply(double dt) {
    applyCircleConstraints();
  }

  void applyCircleConstraints() {
    final center = size / 2;
    for (final particle in particles) {
      final distanceToCircleBorder = particle.position - center;
      final distance = distanceToCircleBorder.length;
      final particleRadius = particle.size.x / 2;

      if (distance > radius - particleRadius) {
        final normal = distanceToCircleBorder / distance;

        particle.position.setValues(
          center.x + normal.x * (radius - particleRadius),
          center.y + normal.y * (radius - particleRadius),
        );
      }
    }
  }

  @override
  void solve(double dt) {
    solveCollisions();
  }

  void solveCollisions() {
    for (var i = 0; i < particles.length; i++) {
      final particle1 = particles[i];
      for (var j = i + 1; j < particles.length; j++) {
        final particle2 = particles[j];

        final collisionAxis = particle1.position - particle2.position;
        final distance = collisionAxis.length;
        final minDistance = particle1.size.x / 2 + particle2.size.x / 2;

        if (distance < minDistance) {
          final penetration = minDistance - distance;
          final normal = (collisionAxis / distance)..scale(0.5 * penetration);

          particle1.position.add(normal);
          particle2.position.sub(normal);
        }
      }
    }
  }

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    position.add(info.delta.game);
    gravity.setFrom(-info.delta.game.clone() * baseGravity.y);
    return false;
  }

  @override
  void update(double dt) {
    gravity.lerp(baseGravity, dt);
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(radius, radius), radius, Paint());
    super.render(canvas);
  }
}

class CircleParticle extends PositionComponent with Particle, HasPaint {
  CircleParticle({
    super.position,
    required double radius,
    required Color color,
  }) : super(size: Vector2.all(radius * 2), anchor: Anchor.center) {
    paint.color = color;
  }

  @override
  void render(Canvas canvas) {
    final center = size / 2;
    canvas.drawCircle(center.toOffset(), center.x, paint);
    super.render(canvas);
  }
}

void main() {
  runApp(GameWidget(game: PhysikExample()));
}
