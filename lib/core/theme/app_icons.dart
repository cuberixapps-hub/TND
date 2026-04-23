import 'package:flutter/material.dart';

/// Custom icon set for modern Truth or Dare app
class AppIcons {
  AppIcons._();

  // Navigation Icons
  static const IconData home = Icons.home_rounded;
  static const IconData back = Icons.arrow_back_ios_new_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData menu = Icons.menu_rounded;
  static const IconData more = Icons.more_horiz_rounded;

  // Game Mode Icons
  static const IconData kids = Icons.child_friendly_rounded;
  static const IconData teens = Icons.school_rounded;
  // Neutral "adult" icon. We deliberately avoid nightlife/alcohol imagery
  // (e.g. Icons.nightlife_rounded / wine_bar) to stay clear of App Review
  // 4.3(b) "drinking game" framing.
  static const IconData adult = Icons.local_fire_department_rounded;
  static const IconData couples = Icons.favorite_rounded;

  // Action Icons
  static const IconData play = Icons.play_arrow_rounded;
  static const IconData pause = Icons.pause_rounded;
  static const IconData stop = Icons.stop_rounded;
  static const IconData restart = Icons.refresh_rounded;
  static const IconData next = Icons.skip_next_rounded;
  static const IconData previous = Icons.skip_previous_rounded;

  // Game Icons
  // Previously `Icons.wine_bar_rounded` — replaced with a neutral spinner
  // arrow so the app’s random picker no longer visually implies a drinking
  // game. Identifier kept as `bottle` for backward code compatibility.
  static const IconData bottle = Icons.refresh_rounded;
  static const IconData spin = Icons.rotate_right_rounded;
  static const IconData truth = Icons.psychology_rounded;
  static const IconData dare = Icons.flash_on_rounded;
  static const IconData challenge = Icons.emoji_events_rounded;
  static const IconData timer = Icons.timer_rounded;

  // UI Icons
  static const IconData add = Icons.add_rounded;
  static const IconData remove = Icons.remove_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_rounded;
  static const IconData check = Icons.check_rounded;
  static const IconData checkCircle = Icons.check_circle_rounded;
  static const IconData error = Icons.error_rounded;
  static const IconData warning = Icons.warning_rounded;
  static const IconData info = Icons.info_rounded;

  // Settings Icons
  static const IconData settings = Icons.settings_rounded;
  static const IconData sound = Icons.volume_up_rounded;
  static const IconData soundOff = Icons.volume_off_rounded;
  static const IconData vibration = Icons.vibration_rounded;
  static const IconData team = Icons.people_rounded;
  static const IconData arrowRight = Icons.arrow_forward_rounded;
  static const IconData notifications = Icons.notifications_rounded;
  static const IconData theme = Icons.palette_rounded;

  // Social Icons
  static const IconData share = Icons.share_rounded;
  static const IconData person = Icons.person_rounded;
  static const IconData group = Icons.group_rounded;
  static const IconData addPerson = Icons.person_add_rounded;

  // Score/Stats Icons
  static const IconData trophy = Icons.emoji_events_rounded;
  static const IconData star = Icons.star_rounded;
  static const IconData leaderboard = Icons.leaderboard_rounded;
  static const IconData stats = Icons.analytics_rounded;

  // Utility Icons
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.filter_list_rounded;
  static const IconData sort = Icons.sort_rounded;
  static const IconData download = Icons.download_rounded;
  static const IconData upload = Icons.upload_rounded;

  // Get icon for game mode
  static IconData getModeIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'kids':
        return kids;
      case 'teens':
        return teens;
      case 'adult':
        return adult;
      case 'couples':
        return couples;
      default:
        return play;
    }
  }

  // Get icon with custom painter for unique designs
  static Widget customIcon(
    IconData icon, {
    double size = 24,
    Color? color,
    List<Color>? gradientColors,
  }) {
    if (gradientColors != null && gradientColors.length >= 2) {
      return ShaderMask(
        shaderCallback:
            (bounds) => LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
        child: Icon(icon, size: size, color: Colors.white),
      );
    }

    return Icon(icon, size: size, color: color);
  }
}
