import 'package:equatable/equatable.dart';

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class AccentChanged extends ThemeEvent {
  const AccentChanged({required this.isPink});

  final bool isPink;

  @override
  List<Object> get props => [isPink];
}

class AppearanceSelected extends ThemeEvent {
  const AppearanceSelected(this.label);

  final String label;

  @override
  List<Object> get props => [label];
}
