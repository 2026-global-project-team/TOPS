import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  final String? errorText;
  final bool enabled;
  final Iterable<String>? autofillHints;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.onSubmitted,
    this.onChanged,
    this.errorText,
    this.enabled = true,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      enabled: enabled,
      autofillHints: autofillHints,
      cursorColor: Colors.white,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
        errorText: errorText,
        errorStyle: const TextStyle(
          color: Color(0xFFFF8A8A),
          fontSize: 12,
        ),
        suffixIcon: suffixIcon,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 1.2,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 2,
          ),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFFF8A8A),
            width: 1.2,
          ),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFFF8A8A),
            width: 2,
          ),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
      ),
    );
  }
}