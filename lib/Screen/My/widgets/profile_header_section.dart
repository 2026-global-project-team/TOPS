import 'package:flutter/material.dart';

class ProfileHeaderSection extends StatelessWidget {
  final String userName;
  final String levelName;
  final String nextLevelName;
  final double levelProgress;
  final String? profileImageUrl;

  const ProfileHeaderSection({
    super.key,
    required this.userName,
    required this.levelName,
    required this.nextLevelName,
    required this.levelProgress,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 340,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 42),
      decoration: const BoxDecoration(
        color: Color(0xFF282828),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    profileImageUrl != null && profileImageUrl!.isNotEmpty
                    ? NetworkImage(profileImageUrl!)
                    : null,
                child: profileImageUrl == null || profileImageUrl!.isEmpty
                    ? const Icon(Icons.person, size: 34, color: Colors.grey)
                    : null,
              ),

              const SizedBox(width: 14),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5F72D9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      levelName,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 34),

          Row(
            children: [
              const Text(
                'My Level',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(width: 6),

              Text(
                levelName,
                style: const TextStyle(color: Color(0xFFD1D1D1), fontSize: 14),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF627BFF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  nextLevelName,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: levelProgress.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: const Color(0xFF777777),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
