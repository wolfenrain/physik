import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:physik/physik.dart';

class ParticleTextComponent<T extends TextRenderer> extends TextComponent {
  ParticleTextComponent({
    required this.solver,
    T? super.textRenderer,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    int? priority,
  }) : super(
          priority: priority ?? double.maxFinite.toInt(),
        );

  final PhysicsSolver solver;

  @override
  void update(double dt) {
    text = 'Particles: ${solver.particles.length}';
  }
}
