import 'package:flutter/material.dart';
import 'package:tops/Screen/login/widgets/arrow_action_button.dart';

class OnboardingStep extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final int currentPage;
  final int pageCount;
  final VoidCallback onNext;

  const OnboardingStep({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.currentPage,
    required this.pageCount,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
      ),
      child: Column(
        children: [
          const SizedBox(height: 60),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pageCount,
                  (index) {
                final isSelected = index == currentPage;

                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.white
                        : Colors.white38,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 26),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const Spacer(),

          Align(
            alignment: Alignment.centerRight,
            child: ArrowActionButton(
              isLoading: false,
              onPressed: onNext,
            ),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}