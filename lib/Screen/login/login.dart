import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tops/services/auth_service.dart';

import 'widgets/login_background.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/Social_login_section.dart';
import 'signUp.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  StreamSubscription<AuthState>? _authSubscription;

  bool _obscurePassword = true;
  bool _isLoading = false;

  // Google 또는 Apple 로그인을 눌렀을 때만 true
  bool _isSocialLoginInProgress = false;

  // 중복 화면 이동 방지
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen(
              (AuthState authState) {
            final AuthChangeEvent event = authState.event;
            final Session? session = authState.session;

            /*
         * 이메일 회원가입으로 signedIn 이벤트가 발생해도
         * 여기서는 이동하지 않는다.
         *
         * Google 또는 Apple 로그인 버튼을 누른 상태에서
         * OAuth 인증이 완료된 경우에만 온보딩으로 이동한다.
         */
            if (event == AuthChangeEvent.signedIn &&
                session != null &&
                _isSocialLoginInProgress &&
                !_isNavigating &&
                mounted) {
              _isNavigating = true;
              _isSocialLoginInProgress = false;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const SignupPage(
                    initialStep: 1,
                  ),
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

            debugPrintStack(
              stackTrace: stackTrace,
            );

            if (mounted) {
              setState(() {
                _isSocialLoginInProgress = false;
                _isLoading = false;
              });
            }
          },
        );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
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
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _login() async {
    if (_isLoading) {
      return;
    }

    final String email =
    _emailController.text.trim();

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

      if (!mounted) {
        return;
      }

      if (response.session == null) {
        _showMessage(
          'Unable to create a login session.',
        );
        return;
      }

      /*
       * 이메일 로그인은 함수 결과로 세션을 바로 확인할 수 있으므로
       * 여기에서 직접 온보딩으로 이동한다.
       */
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const SignupPage(
            initialStep: 1,
          ),
        ),
            (route) => false,
      );
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _convertAuthError(error.message),
      );
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }

      debugPrint(
        'Email login error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

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

  Future<void> _signInWithGoogle() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isSocialLoginInProgress = true;
      _isNavigating = false;
    });

    try {
      final bool launched =
      await AuthService.signInWithGoogle();

      if (!mounted) {
        return;
      }

      if (!launched) {
        setState(() {
          _isLoading = false;
          _isSocialLoginInProgress = false;
        });

        _showMessage(
          'Unable to open the Google login page.',
        );
      }

      /*
       * 여기서 _isLoading을 false로 만들지 않는다.
       * Google 인증 완료 후 onAuthStateChange가 화면 이동을 처리한다.
       */
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _isSocialLoginInProgress = false;
      });

      _showMessage(
        'Google login failed: ${error.message}',
      );
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _isSocialLoginInProgress = false;
      });

      debugPrint(
        'Google login error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _showMessage(
        'Google login failed. Please try again.',
      );
    }
  }

  Future<void> _signInWithApple() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isSocialLoginInProgress = true;
      _isNavigating = false;
    });

    try {
      final bool launched =
      await AuthService.signInWithApple();

      if (!mounted) {
        return;
      }

      if (!launched) {
        setState(() {
          _isLoading = false;
          _isSocialLoginInProgress = false;
        });

        _showMessage(
          'Unable to open the Apple login page.',
        );
      }
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _isSocialLoginInProgress = false;
      });

      _showMessage(
        'Apple login failed: ${error.message}',
      );
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _isSocialLoginInProgress = false;
      });

      debugPrint(
        'Apple login error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _showMessage(
        'Apple login failed. Please try again.',
      );
    }
  }

  void _moveToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SignupPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
        Brightness.light,
        statusBarBrightness:
        Brightness.dark,
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
                      controller: _emailController,
                      hintText: 'e-mail',
                      keyboardType:
                      TextInputType.emailAddress,
                      textInputAction:
                      TextInputAction.next,
                    ),

                    const SizedBox(height: 32),

                    AuthTextField(
                      controller:
                      _passwordController,
                      hintText: 'Password',
                      obscureText:
                      _obscurePassword,
                      textInputAction:
                      TextInputAction.done,
                      onSubmitted: (_) {
                        _login();
                      },
                      suffixIcon: IconButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                          setState(() {
                            _obscurePassword =
                            !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons
                              .visibility_off_outlined
                              : Icons
                              .visibility_outlined,
                          color: Colors.white70,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Align(
                      alignment:
                      Alignment.centerRight,
                      child: ArrowLoginButton(
                        isLoading: _isLoading,
                        onPressed: _login,
                      ),
                    ),

                    const SizedBox(height: 22),

                    SocialLoginSection(
                      onApplePressed:
                      _signInWithApple,
                      onGooglePressed:
                      _signInWithGoogle,
                    ),

                    const Spacer(),

                    Center(
                      child: Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          const Text(
                            'Don’t have an account? ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : _moveToSignup,
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                color:
                                Color(0xFF718CFF),
                                fontSize: 12,
                                fontWeight:
                                FontWeight.w600,
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
  const LoginHeadline({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const TextStyle normalStyle =
    TextStyle(
      color: Colors.white,
      fontSize: 38,
      fontWeight: FontWeight.w300,
      height: 1.38,
    );

    const TextStyle boldStyle =
    TextStyle(
      color: Colors.white,
      fontSize: 38,
      fontWeight: FontWeight.w700,
      height: 1.38,
    );

    return const Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
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
      onTap: isLoading
          ? null
          : onPressed,
      borderRadius:
      BorderRadius.circular(30),
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
          child:
          CircularProgressIndicator(
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