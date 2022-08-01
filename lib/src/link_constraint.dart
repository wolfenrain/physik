import 'dart:ui';

import 'package:flame/components.dart';
import 'package:physik/physik.dart';

/// {@template link_constraint}
/// Constraint two particles to each other.
/// {@endtemplate}
class LinkConstraint extends Component {
  /// {@macro link_constraint}
  LinkConstraint({
    required this.particle1,
    required this.particle2,
    required this.distance,
    this.maxElongationRatio = 1.5,
    this.strength = 1,
  });

  /// The first particle of the constraint.
  final Particle particle1;

  /// The second particle of the constraint.
  final Particle particle2;

  /// The allowed distance between the particles.
  final double distance;

  /// Determines the pulling force on the constraint.
  final double strength;

  /// The max elongation of the constraint. This will determine if the
  /// distance between the particles is allowed to be longer or shorter.
  final double maxElongationRatio;

  /// Indicates if the constraint has been broken or not.
  bool get broken => _broken;
  bool _broken = false;

  /// It is valid if both particles are still mounted and the constraint is
  /// not broken.
  bool get isValid => particle1.isMounted && particle2.isMounted && !broken;

  /// Solve the constraint. This will move the particles to the correct
  /// distance or break the constraint if the distance is too long.
  void solve() {
    if (!isValid) return;

    final distanceBetween = particle1.position - particle2.position;
    final currentDistance = distanceBetween.length;

    if (currentDistance > distance) {
      // Break if the distance is over the given threshold.
      _broken = currentDistance > distance * maxElongationRatio;

      final normal = distanceBetween / currentDistance;
      final delta = distance - currentDistance;
      final pullingForce =
          normal * -(delta * strength) / (particle1.mass + particle2.mass);

      // Apply the pulling force to both particles.
      if (particle1.isMoving) {
        particle1.position.sub(pullingForce / particle1.mass);
      }
      if (particle2.isMoving) {
        particle2.position.add(pullingForce / particle2.mass);
      }
    }
  }

  @override
  void renderDebugMode(Canvas canvas) {
    canvas.drawLine(
      particle1.position.toOffset(),
      particle2.position.toOffset(),
      debugPaint,
    );
  }
}
