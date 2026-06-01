import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final int? maxLength;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.maxLines = 1,
    this.inputFormatters,
    this.validator,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white.withOpacity(0.4) : Colors.black38;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);
    final fillColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor.withOpacity(0.9),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          style: TextStyle(color: textColor, fontSize: 16),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: hintColor),
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, color: theme.colorScheme.primary) : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Iconsax.eye_slash : Iconsax.eye,
                      color: textColor.withOpacity(0.5),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

