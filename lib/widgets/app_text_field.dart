import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int maxLines;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool readOnly;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final AutovalidateMode? autovalidateMode;

  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffix,
    this.readOnly = false,
    this.onChanged,
    this.onFieldSubmitted,
    this.autovalidateMode,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          readOnly: widget.readOnly,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          autovalidateMode: widget.autovalidateMode,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 20, color: Colors.grey.shade600)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffix,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
            ),
            errorStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.redAccent,
            ),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}
