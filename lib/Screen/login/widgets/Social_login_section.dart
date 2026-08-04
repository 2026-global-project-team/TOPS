import 'package:flutter/material.dart';

class SocialLoginSection extends StatelessWidget {
  final VoidCallback onApplePressed;
  final VoidCallback onGooglePressed;

  const SocialLoginSection({
    super.key,
    required this.onApplePressed,
    required this.onGooglePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Or continue with',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 16),

        SocialLoginButton(
          backgroundColor: const Color(0xFF252525),
          foregroundColor: Colors.white,
          icon: const Icon(
            Icons.apple,
            size: 22,
            color: Colors.white,
          ),
          text: 'Continue with Apple',
          onPressed: onApplePressed,
        ),

        const SizedBox(height: 12),

        SocialLoginButton(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF292929),
          icon: Image.asset(
            'assets/images/google_icon.png',
            width: 22,
            height: 22,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          text: 'Continue with Google',
          onPressed: onGooglePressed,
        ),
      ],
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget icon;
  final String text;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
        ),
        child: Row(
          children: [
            // Apple과 Google 모두 같은 크기의 영역에 배치
            SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: icon,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // 텍스트를 버튼 중앙에 맞추기 위한 빈 공간
            const SizedBox(width: 36),
          ],
        ),
      ),
    );
  }
}