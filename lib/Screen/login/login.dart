import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tops/Main/main_shell.dart';
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

  bool _isNavigating = false;

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

  String _convertAuthError(String message) {
    final String lowerMessage =
    message.toLowerCase();

    if (lowerMessage.contains(
      'invalid login credentials',
    )) {
      return 'Incorrect email or password.';
    }

    if (lowerMessage.contains(
      'email not confirmed',
    )) {
      return 'Please verify your email before logging in.';
    }

    if (lowerMessage.contains(
      'too many requests',
    )) {
      return 'Too many attempts. Please try again later.';
    }

    return message;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  Future<void> _login() async {
    final String email =
    _usernameController.text.trim();

    final String password =
        _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage(
        'Please enter your email and password.',
      );
      return;
    }

    if (!email.contains('@')) {
      _showMessage(
        'Please enter a valid email address.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse response =
      await AuthService.signInWithEmail(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (response.session == null) {
        _showMessage(
          'Unable to create a login session.',
        );
        return;
      }

      /*
     * 화면 이동은 initState의
     * onAuthStateChange listener가 처리한다.
     */
    } on AuthException catch (error) {
      if (!mounted) return;

      _showMessage(
        _convertAuthError(error.message),
      );
    } catch (error) {
      if (!mounted) return;

      debugPrint('Email login error: $error');

      _showMessage(
        'Login failed. Please try again.',
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
    try {
      final bool launched =
      await AuthService.signInWithApple();

      if (!launched && mounted) {
        _showMessage(
          'Unable to open the Apple login page.',
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      _showMessage(
        'Apple login failed: ${error.message}',
      );
    } catch (error) {
      if (!mounted) return;

      debugPrint('Apple login error: $error');

      _showMessage(
        'Apple login failed. Please try again.',
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final bool launched =
      await AuthService.signInWithGoogle();

      if (!launched && mounted) {
        _showMessage(
          'Unable to open the Google login page.',
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      _showMessage(
        'Google login failed: ${error.message}',
      );
    } catch (error) {
      if (!mounted) return;

      debugPrint('Google login error: $error');

      _showMessage(
        'Google login failed. Please try again.',
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
        Supabase.instance.client.auth
            .onAuthStateChange
            .listen(
              (AuthState authState) {
            final AuthChangeEvent event =
                authState.event;

            final Session? session =
                authState.session;

            if (event ==
                AuthChangeEvent.signedIn &&
                session != null &&
                mounted &&
                !_isNavigating) {
              _isNavigating = true;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const MainShell(),
                ),
                    (route) => false,
              );
            }
          },
          onError: (
              Object error,
              StackTrace stackTrace,
              ) {
            debugPrint(
              'Authentication listener error: $error',
            );
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