import 'package:flutter/material.dart';


class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onpressed;
  const CustomButton({super.key, required this.text, required this.onpressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 59, 118, 167),
        minimumSize: Size(double.infinity, 40),
      ),
      onPressed: onpressed,
      child: Text(
        text,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}