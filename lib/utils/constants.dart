import 'package:flutter/material.dart';

class AppColors {
  // Sunny
  static const Color sunnyPrimary = Color(0xFFFDB813);
  static const Color sunnyBackground = Color(0xFF87CEEB);
  
  // Rainy
  static const Color rainyPrimary = Color(0xFF4A5568);
  static const Color rainyBackground = Color(0xFF718096);
  
  // Cloudy
  static const Color cloudyPrimary = Color(0xFFA0AEC0);
  static const Color cloudyBackground = Color(0xFFCBD5E0);
  
  // Night / Default
  static const Color nightPrimary = Color(0xFF2D3748);
  static const Color nightBackground = Color(0xFF1A202C);

  static LinearGradient getGradient(String? condition) {
    if (condition == null) {
      return const LinearGradient(
        colors: [nightBackground, nightPrimary],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }

    String main = condition.toLowerCase();
    
    if (main.contains('rain') || main.contains('drizzle') || main.contains('thunder')) {
      return const LinearGradient(
        colors: [rainyPrimary, rainyBackground],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (main.contains('cloud')) {
       return const LinearGradient(
        colors: [cloudyPrimary, cloudyBackground],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (main.contains('clear') || main.contains('sun')) {
       return const LinearGradient(
        colors: [sunnyBackground, sunnyPrimary],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
       return const LinearGradient(
        colors: [nightBackground, nightPrimary],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
  }
}

class AppTextStyles {
  static const TextStyle header = TextStyle(
    fontFamily: 'Roboto', 
    fontSize: 32, 
    fontWeight: FontWeight.bold, 
    color: Colors.white,
    shadows: [Shadow(blurRadius: 2, color: Colors.black26, offset: Offset(1,1))]
  );
  
  static const TextStyle tempBig = TextStyle(
    fontFamily: 'Roboto', 
    fontSize: 80, 
    fontWeight: FontWeight.w300, 
    color: Colors.white
  );
  
  static const TextStyle body = TextStyle(
    fontFamily: 'Roboto', 
    fontSize: 16, 
    color: Colors.white
  );
  
  static const TextStyle label = TextStyle(
    fontFamily: 'Roboto', 
    fontSize: 14, 
    color: Colors.white70
  );
}