import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tops/services/auth_service.dart';

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
  State<SignupFormStep> createState() =>
      _SignupFormStepState();
}

class _SignupFormStepState extends State<SignupFormStep> {
  final TextEditingController _usernameController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  StreamSubscription<AuthState>? _authSubscription;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  bool _isSocialLoginInProgress = false;
  bool _hasMovedToOnboarding = false;

  @override
  void initState() {
    super.initState();

    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen(
              (AuthState authState) {
            final AuthChangeEvent event = authState.event;
            final Session? session = authState.session;

            if (event == AuthChangeEvent.signedIn &&
                session != null &&
                _isSocialLoginInProgress &&
                !_hasMovedToOnboarding &&
                mounted) {
              _hasMovedToOnboarding = true;
              _isSocialLoginInProgress = false;

              widget.onNext();
            }
          },
          onError: (
              Object error,
              StackTrace stackTrace,
              ) {
            debugPrint(
              'Sign-up authentication listener error: $error',
            );

            debugPrintStack(
              stackTrace: stackTrace,
            );

            if (mounted) {
              setState(() {
                _isLoading = false;
                _isSocialLoginInProgress = false;
              });

              _showMessage(
                'Social login failed. Please try again.',
              );
            }
          },
        );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();

    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _handleSocialLoginCompleted() async {
    if (_hasMovedToOnboarding) {
      return;
    }

    _hasMovedToOnboarding = true;
    _isSocialLoginInProgress = false;

    try {
      await AuthService.createSocialProfileIfNeeded();

      if (!mounted) {
        return;
      }

      widget.onNext();
    } on PostgrestException catch (error) {
      _hasMovedToOnboarding = false;

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      debugPrint(
        'Social profile creation error: ${error.message}',
      );

      _showMessage(
        'Your account was created, but your profile could not be saved.',
      );
    } catch (error, stackTrace) {
      _hasMovedToOnboarding = false;

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      debugPrint(
        'Social profile creation error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _showMessage(
        'Your profile could not be created.',
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        46,
        28,
        46,
        30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Join TOPS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Discover new places.\n'
                'Create your own stories.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 38),

          AuthTextField(
            controller: _usernameController,
            hintText: 'Username',
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 14),

          AuthTextField(
            controller: _emailController,
            hintText: 'e-mail',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 14),

          AuthTextField(
            controller: _passwordController,
            hintText: 'Password',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
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
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 14),

          AuthTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirm Password',
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              _handleSignUp();
            },
            suffixIcon: IconButton(
              onPressed: _isLoading
                  ? null
                  : () {
                setState(() {
                  _obscureConfirmPassword =
                  !_obscureConfirmPassword;
                });
              },
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Align(
            alignment: Alignment.centerRight,
            child: _buildNextButton(),
          ),

          const SizedBox(height: 20),

          SocialLoginSection(
            onApplePressed: _handleAppleSignIn,
            onGooglePressed: _handleGoogleSignIn,
          ),

          const SizedBox(height: 38),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              GestureDetector(
                onTap: _isLoading
                    ? null
                    : widget.onLoginPressed,
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Color(0xFF5172FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    if (_isLoading) {
      return const SizedBox(
        width: 52,
        height: 52,
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    return ArrowActionButton(
      onPressed: _handleSignUp,
    );
  }

  Future<void> _handleSignUp() async {
    if (_isLoading) {
      return;
    }

    final String userName =
    _usernameController.text.trim();

    final String email =
    _emailController.text.trim();

    final String password =
        _passwordController.text;

    final String confirmPassword =
        _confirmPasswordController.text;

    if (userName.isEmpty) {
      _showMessage(
        'Please enter your username.',
      );
      return;
    }

    if (userName.length < 2) {
      _showMessage(
        'Username must be at least 2 characters.',
      );
      return;
    }

    if (email.isEmpty) {
      _showMessage(
        'Please enter your e-mail.',
      );
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage(
        'Please enter a valid e-mail address.',
      );
      return;
    }

    if (password.isEmpty) {
      _showMessage(
        'Please enter your password.',
      );
      return;
    }

    if (password.length < 6) {
      _showMessage(
        'Password must be at least 6 characters.',
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      _showMessage(
        'Please confirm your password.',
      );
      return;
    }

    if (password != confirmPassword) {
      _showMessage(
        'Passwords do not match.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse response =
      await AuthService.signUpWithEmail(
        email: email,
        password: password,
        userName: userName,
        location: 'London',
      );

      if (!mounted) {
        return;
      }

      if (response.user == null) {
        _showMessage(
          'The account could not be created.',
        );
        return;
      }

      if (response.session == null) {
        _showMessage(
          'Please check your e-mail to verify your account.',
        );
        return;
      }

      if (!_hasMovedToOnboarding) {
        _hasMovedToOnboarding = true;
        widget.onNext();
      }
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _getAuthErrorMessage(error.message),
      );
    } on PostgrestException catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint(
        'Profile creation error: ${error.message}',
      );

      _showMessage(
        'Your account was created, but your profile could not be saved.',
      );
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }

      debugPrint(
        'Sign-up error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isSocialLoginInProgress = true;
      _hasMovedToOnboarding = false;
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
          'Google sign in could not be started.',
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
        _getAuthErrorMessage(error.message),
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
        'Google sign-in error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _showMessage(
        'Google sign in failed.',
      );
    }
  }

  Future<void> _handleAppleSignIn() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isSocialLoginInProgress = true;
      _hasMovedToOnboarding = false;
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
          'Apple sign in could not be started.',
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
        _getAuthErrorMessage(error.message),
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
        'Apple sign-in error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _showMessage(
        'Apple sign in failed.',
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  String _getAuthErrorMessage(
      String message,
      ) {
    final String lowerMessage =
    message.toLowerCase();

    if (lowerMessage.contains(
      'user already registered',
    )) {
      return 'This e-mail is already registered.';
    }

    if (lowerMessage.contains(
      'invalid email',
    )) {
      return 'Please enter a valid e-mail address.';
    }

    if (lowerMessage.contains(
      'password should be',
    )) {
      return 'Please use a stronger password.';
    }

    if (lowerMessage.contains(
      'network',
    )) {
      return 'Please check your internet connection.';
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
}