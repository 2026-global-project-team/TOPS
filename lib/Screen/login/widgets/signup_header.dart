import 'package:flutter/material.dart';

class SignupHeader extends StatelessWidget {
  final int currentStep;

  const SignupHeader({
    super.key,
    required this.currentStep,
  });

  double getProgress(){
    if(currentStep == 0){
      return 0.333;
    }
    else if(currentStep >= 1 && currentStep <= 3){
      return 0.666;
    }
    else if(currentStep == 4) return 1.0;
    else return 0.333;
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                ),
              ),
              const Expanded(
                child: Text(
                  'Sign up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: getProgress(),
            minHeight: 3,
            backgroundColor: Colors.white38,
            valueColor: const AlwaysStoppedAnimation<Color>(
              Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}