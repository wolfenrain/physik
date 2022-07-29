import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:physik/physik.dart';

void main() {
  runApp(GameWidget(game: ClothSimulation()));
}

class ClothSimulation extends FlameGame with HasDraggables {
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
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    super.onDragUpdate(pointerId, info);

    applyForceOnCloth(info.eventPosition.game, info.delta.game * 1500);
  }

  void applyForceOnCloth(Vector2 position, Vector2 force) {
    final solver = firstChild<PhysicsSolver>()!;
    for (final particle in solver.particles) {
      if (inRadius(particle, position, 100)) {
        particle.forces.add(force);
      }
    }
  }

  bool inRadius(Particle particle, Vector2 center, double radius) {
    final distance = particle.position - center;
    return distance.x * distance.x + distance.y * distance.y < radius * radius;
  }
}

class ClothPhysicsSolver extends Component with PhysicsSolver {
  @override
  void apply(double dt) {}

  @override
  void solve(double dt) {}
}

class ClothParticle extends PositionComponent with Particle {
  ClothParticle({super.position});
}
