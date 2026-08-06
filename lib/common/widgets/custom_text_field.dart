import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: labelText,
      ),
    );
  }
}
