import '../constants/app_constants.dart';

// Extension to safely get enum name for GameMode
extension GameModeExtension on GameMode {
  String get enumName {
    final name = toString().split('.').last;
    // Capitalize first letter
    return name[0].toUpperCase() + name.substring(1);
  }
}
