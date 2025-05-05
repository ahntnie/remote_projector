import 'package:flutter/material.dart';

class GradientLoadingWidget extends StatelessWidget {
  final bool showFull;

  const GradientLoadingWidget({super.key, this.showFull = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: showFull ? MediaQuery.of(context).size.width : 200,
      height: 5,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            colors: [Colors.blue, Colors.red],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds);
        },
        child: const LinearProgressIndicator(
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      ),
    );
  }
}
