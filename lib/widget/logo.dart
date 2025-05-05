import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;

  const LogoWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/img_logo.png'),
        ),
      ),
    );
  }
}
