import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tops/Main/widgets/polaroidCard.dart';

class SignupCompleteStep extends StatelessWidget {
  final VoidCallback onStartExploring;

  const SignupCompleteStep({
    super.key,
    required this.onStartExploring,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        32,
        36,
        32,
        28,
      ),
      child: Column(
        children: [
          // Welcome to TOPS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w600,
                ),
              ),
              //여기 TOPS.svg 가지고옴.
              SvgPicture.asset('assets/images/TOPS.svg',
                width: 90,
                height: 44,
              ),
            ],
          ),

          const SizedBox(height: 22),

          const Text(
            'Your journey starts here!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 58),

          // 겹쳐진 폴라로이드 이미지
          SizedBox(
            width: screenSize.width * 0.72,
            height: screenSize.height * 0.34,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                    offset: const Offset(45, 0),
                    child: Transform.rotate(
                      angle: 0.28,
                      child: PolaroidCard(
                        width: screenSize.width * 0.55,
                        height: screenSize.height * 0.30,
                        image: Image.asset(
                          'assets/images/welcome_back.png',
                          fit: BoxFit.cover,
                        )
                      ),
                    ),
                ),

                Transform.rotate(
                  angle: 0,
                  child: PolaroidCard(
                    width: screenSize.width * 0.55,
                    height: screenSize.height * 0.30,
                    image: Image.asset(
                      'assets/images/welcome_front.png',
                      fit: BoxFit.cover,
                    )
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Start Exploring 버튼
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: onStartExploring,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor:
                const Color(0xFF6379FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Start Exploring',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}