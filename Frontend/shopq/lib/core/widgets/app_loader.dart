import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AppLoader extends StatelessWidget {
  final double size;
  const AppLoader({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
