import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  const ThemeState({
    required this.isPink,
    required this.themeMode,
    required this.appearanceLabel,
  });

  final bool isPink;
  final ThemeMode themeMode;
  final String appearanceLabel;

  ThemeState copyWith({
    bool? isPink,
    ThemeMode? themeMode,
    String? appearanceLabel,
  }) {
    return ThemeState(
      isPink: isPink ?? this.isPink,
      themeMode: themeMode ?? this.themeMode,
      appearanceLabel: appearanceLabel ?? this.appearanceLabel,
    );
  }

  @override
  List<Object> get props => [isPink, themeMode, appearanceLabel];
}
