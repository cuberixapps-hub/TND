import '../constants/app_constants.dart';

// Extension to safely get enum name for GameMode
extension GameModeExtension on GameMode {
  String get enumName => toString().split('.').last;
}
