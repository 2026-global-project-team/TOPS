import 'package:flutter/material.dart';

import 'auth_text_field.dart';
import 'arrow_action_button.dart';
import 'social_login_section.dart';

class SignupFormStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onLoginPressed;

  const SignupFormStep({
    super.key,
    required this.onNext,
    required this.onLoginPressed,
  });

  @override
  State<SignupFormStep> createState() => _SignupFormStepState();
}

class _SignupFormStepState extends State<SignupFormStep> {
  final TextEditingController _usernameController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 항목을 입력해주세요.'),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호가 일치하지 않습니다.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Supabase 회원가입 연결
      debugPrint('회원가입 Username: $username');

      await Future<void>.delayed(
        const Duration(seconds: 1),
      );

      if (!mounted) return;

      // 회원가입이 성공하면 다음 온보딩 단계로 이동
      widget.onNext();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원가입 실패: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithApple() async {
    debugPrint('Apple 회원가입');
  }

  Future<void> _signInWithGoogle() async {
    debugPrint('Google 회원가입');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        46,
        36,
        46,
        28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Join TOPS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Discover new places.\nCreate your own stories.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 58),

          AuthTextField(
            controller: _usernameController,
            hintText: 'Username',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 18),

          AuthTextField(
            controller: _passwordController,
            hintText: 'Password',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white70,
              ),
            ),
          ),

          const SizedBox(height: 18),

          AuthTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirm Password',
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _signUp(),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword =
                  !_obscureConfirmPassword;
                });
              },
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white70,
              ),
            ),
          ),

          const SizedBox(height: 26),

          Align(
            alignment: Alignment.centerRight,
            child: ArrowActionButton(
              isLoading: _isLoading,
              onPressed: _signUp,
            ),
          ),

          const SizedBox(height: 54),

          SocialLoginSection(
            onApplePressed: _signInWithApple,
            onGooglePressed: _signInWithGoogle,
          ),

          const SizedBox(height: 50),

          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onLoginPressed,
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Color(0xFF718CFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}