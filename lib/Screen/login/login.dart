import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tops/Screen/Explore/pages/explore_page.dart';
import 'widgets/login_background.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/Social_login_section.dart';
import 'signUp.dart';
import 'dart:async';
import 'package:tops/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  StreamSubscription<AuthState>? _authSubscription;

  final TextEditingController _usernameController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _authSubscription?.cancel();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '아이디와 비밀번호를 입력해주세요.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Supabase 이메일 로그인 연결
      debugPrint('Username: $username');

      // await supabase.auth.signInWithPassword(
      //   email: username,
      //   password: password,
      // );
      await Future<void>.delayed(
        const Duration(seconds: 1),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 실패: $error'),
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
    // TODO: Supabase Apple 로그인 연결
    debugPrint('Apple 로그인');
    //await Supabase.instance.client.auth.signInWithOAuth(
    //   OAuthProvider.apple,
    // );
  }

  Future<void> _signInWithGoogle() async {
    try {
      final launched =
      await AuthService.signInWithGoogle();

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Google 로그인 화면을 열지 못했습니다.',
            ),
          ),
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google 로그인 실패: ${error.message}',
          ),
        ),
      );
    }
  }

  void _moveToSignup() {
    debugPrint('회원가입 화면 이동');

    // SignupPage를 만든 후 아래 코드 사용

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignupPage(),
      ),
    );

  }

  @override
  void initState() {
    super.initState();

    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen(
              (authState) {
            final event = authState.event;
            final session = authState.session;

            if (event == AuthChangeEvent.signedIn && session != null && mounted) {
              // TODO: 로그인 완료 후 이동할 화면으로 변경
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExplorePage(),
                ),
              );
            }
          },
          onError: (error, stackTrace) {
            debugPrint('인증 상태 감지 오류: $error');
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return loginBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 34,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 81),

                    const LoginHeadline(),

                    const Spacer(),

                    AuthTextField(
                      controller: _usernameController,
                      hintText: 'Username',
                      keyboardType:
                      TextInputType.emailAddress,
                      textInputAction:
                      TextInputAction.next,
                    ),

                    const SizedBox(height: 32),

                    AuthTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: _obscurePassword,
                      textInputAction:
                      TextInputAction.done,
                      onSubmitted: (_) => _login(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                            !_obscurePassword;
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

                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ArrowLoginButton(
                        isLoading: _isLoading,
                        onPressed: _login,
                      ),
                    ),

                    const SizedBox(height: 22),

                    SocialLoginSection(
                      onApplePressed: _signInWithApple,
                      onGooglePressed: _signInWithGoogle,
                    ),

                    const Spacer(),

                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Don’t have an account? ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          GestureDetector(
                            onTap: _moveToSignup,
                            child: const Text(
                              'Sign up',
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

                    const SizedBox(height: 34),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LoginHeadline extends StatelessWidget {
  const LoginHeadline({super.key});

  @override
  Widget build(BuildContext context) {
    const normalStyle = TextStyle(
      color: Colors.white,
      fontSize: 38,
      fontWeight: FontWeight.w300,
      height: 1.38,
    );

    const boldStyle = TextStyle(
      color: Colors.white,
      fontSize: 38,
      fontWeight: FontWeight.w700,
      height: 1.38,
    );

    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discover',
          style: boldStyle,
        ),
        Text(
          'Local',
          style: normalStyle,
        ),
        Text(
          'Collect',
          style: boldStyle,
        ),
        Text(
          'Stories',
          style: normalStyle,
        ),
      ],
    );
  }
}

class ArrowLoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const ArrowLoginButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 54,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(
          Icons.arrow_forward,
          color: Colors.white,
          size: 25,
        ),
      ),
    );
  }
}