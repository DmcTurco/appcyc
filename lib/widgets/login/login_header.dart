import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        SvgPicture.asset(
          'assets/svg/logo.svg',
          height: 120,
        ),
        const SizedBox(height: 40),
        const Text(
          'Portal Técnico',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E4C90),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Instalaciones de Gas Natural',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
