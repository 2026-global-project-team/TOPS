import 'package:flutter/material.dart';
import 'package:tops/Screen/login/widgets/login_background.dart';
import 'package:tops/Screen/login/widgets/signup_header.dart';
import 'package:tops/Main/main_shell.dart';
import 'widgets/onboarding_step.dart';
import 'widgets/signup_form_step.dart';
import 'signup_complete_step.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return loginBackground(
      child: Column(
        children: [
          SignupHeader (
            currentStep: _currentStep,
          ),

          Expanded(
            child: _buildStepContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return SignupFormStep(
          onNext: _nextStep,
          onLoginPressed: () {
            Navigator.pop(context);
          },
        );

      case 1:
        return OnboardingStep(
          imagePath: 'assets/images/onboarding_1.png',
          title: 'Discover more than the landmarks',
          description:
          'Find hidden gems and explore local places beyond the tourist trail.',
          currentPage: 0,
          pageCount: 3,
          onNext: _nextStep,
        );

      case 2:
        return OnboardingStep(
          imagePath: 'assets/images/onboarding_2.png',
          title: 'Your journey supports\nlocal communities',
          description:
          'Discover local cafés, shops, and cultural spaces that make each neighborhood unique.',
          currentPage: 1,
          pageCount: 3,
          onNext: _nextStep,
        );

      case 3:
        return OnboardingStep(
          imagePath: 'assets/images/onboarding_3.png',
          title: 'Discover locally. Travel responsibly.',
          description:
          'Explore local places and support the communities behind them.',
          currentPage: 2,
          pageCount: 3,
          onNext: _nextStep,
        );

      case 4:
        return SignupCompleteStep(
          onStartExploring: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const MainShell(),
              ),
                  (route) => false,
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }
}