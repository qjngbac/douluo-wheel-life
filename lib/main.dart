import 'package:flutter/widgets.dart';

import 'app.dart';
import 'engine/game_engine.dart';
import 'state/game_controller.dart';
import 'storage/game_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = GameController(
    engine: GameEngine.production(),
    repository: await SharedPreferencesGameRepository.create(),
  );
  await controller.load();
  runApp(SoulWheelApp(controller: controller));
}
