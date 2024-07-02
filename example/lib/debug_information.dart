import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';
import 'package:physik/physik.dart';

class DebugInformation extends PositionComponent {
  DebugInformation({
    required this.solver,
  }) : super(children: [FpsComponent()]);

  final PhysicsSolver solver;

  double get fps => firstChild<FpsComponent>()?.fps ?? 0;

  @override
  void render(Canvas canvas) {
    _debugText.render(
      canvas,
      '''
FPS: ${fps.toStringAsFixed(2)}
Particles: ${solver.particles.length}
Constraints: ${solver.constraints.length}
''',
      Vector2.zero(),
    );
  }

  static final _debugText = TextPaint(
    style: const TextStyle(
      fontSize: 16,
    ),
  );
}
