import 'package:flutter/material.dart';

class CostumTextfield extends StatelessWidget {
  final String hint;
  final Icon icon;
  final Function(String)? onChanged;
  final FormFieldValidator<String>? validator;
  bool obscure;
  TextCapitalization capitalization;
  CostumTextfield({
    required this.icon,
    required this.hint,
    required this.onChanged,
    required this.validator,
    this.obscure = false,
    this.capitalization = TextCapitalization.none,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextFormField(
        validator: validator,
        obscureText: obscure,
        onChanged: onChanged,
        textInputAction: TextInputAction.next,
        textCapitalization: capitalization,
        style: TextStyle(fontWeight: FontWeight.bold),
        cursorColor: Colors.blueGrey,
        decoration: InputDecoration(
          prefixIcon: icon,
          prefixIconColor: Colors.blueGrey,
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blueGrey, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blueGrey),
          ),
        ),
      ),
    );
  }
}
