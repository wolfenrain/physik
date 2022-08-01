import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:physik/physik.dart';

class ClothSimulation extends FlameGame with HasDraggables {
  final dragForceRadius = 20.0;
  final draggingPoints = <int, Vector2>{};
  final draggingForces = <int, Vector2>{};

  @override
  Future<void>? onLoad() {
    add(FpsTextComponent());

    final solver = ClothPhysicsSolver();
    add(solver);

    const amount = 50;
    const linkLength = 10.0;
    final particles = <String, Particle>{};
    for (var y = 0.0; y < amount; y++) {
      final maxElongation = 1.5 * (2.0 - y / amount);

      for (var x = 0.0; x < amount; x++) {
        final particle = ClothParticle(
          position: Vector2(x * linkLength, y * linkLength),
        );
        solver.add(particle);
        particles['$x-$y'] = particle;

        // Add left constraint if there is a particle on the left.
        if (x > 0) {
          final left = particles['${x - 1}-$y']!;
          solver.add(
            LinkConstraint(
              particle1: left,
              particle2: particle,
              distance: linkLength,
              maxElongationRatio: maxElongation * 0.9,
            )..debugMode = true,
          );
        }

        // Add top constraint if there is a particle on the top.
        if (y > 0) {
          final top = particles['$x-${y - 1}']!;
          solver.add(
            LinkConstraint(
              particle1: top,
              particle2: particle,
              distance: linkLength,
            )..debugMode = true,
          );
        } else {
          particle.isMoving = false;
        }
      }
    }
    return null;
  }

  @override
  void onDragCancel(int pointerId) {
    draggingPoints.remove(pointerId);
    draggingForces.remove(pointerId);

    super.onDragCancel(pointerId);
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    draggingPoints.remove(pointerId);
    draggingForces.remove(pointerId);

    super.onDragEnd(pointerId, info);
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    draggingPoints[pointerId] = info.eventPosition.game;
    draggingForces[pointerId] = info.delta.game * 1500;

    super.onDragUpdate(pointerId, info);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    for (final point in draggingPoints.values) {
      canvas.drawCircle(point.toOffset(), dragForceRadius, debugPaint);
    }
  }
}

class ClothPhysicsSolver extends Component
    with PhysicsSolver, HasGameRef<ClothSimulation> {
  @override
  void apply(double dt) {
    applyForceOnCloth();
  }

  @override
  void solve(double dt) {}

  void applyForceOnCloth() {
    if (gameRef.draggingPoints.isEmpty) return;

    final solver = gameRef.firstChild<PhysicsSolver>()!;
    for (final particle in solver.particles) {
      for (final point in gameRef.draggingPoints.entries) {
        if (inRadius(particle, point.value, gameRef.dragForceRadius)) {
          particle.forces.add(gameRef.draggingForces[point.key]!);
        }
      }
    }
  }

  bool inRadius(Particle particle, Vector2 center, double radius) {
    final distance = particle.position - center;
    return distance.length2 < radius * radius;
  }
}

class ClothParticle extends PositionComponent with Particle {
  ClothParticle({super.position});
}

void main() {
  runApp(GameWidget(game: ClothSimulation()));
}
