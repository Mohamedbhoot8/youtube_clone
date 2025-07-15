import 'package:flutter/material.dart';

class CustomeText extends StatelessWidget {
  const CustomeText(
      {super.key,
      required this.title,
      this.maxline,
      this.size,
      this.weight,
      this.color = Colors.white});

  final String title;
  final int? maxline;
  final double? size;
  final FontWeight? weight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: maxline,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: weight,
      ),
    );
  }
}
