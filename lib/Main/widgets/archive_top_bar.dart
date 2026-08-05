import 'package:flutter/material.dart';

class ArchiveTopBar extends StatelessWidget {
  final String userName;
  final String location;
  final String? profileImageUrl;
  final VoidCallback onProfilePressed;
  final VoidCallback? onLocationPressed;

  const ArchiveTopBar({
    super.key,
    required this.userName,
    required this.location,
    required this.onProfilePressed,
    this.profileImageUrl,
    this.onLocationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 왼쪽 인사말 + 위치
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning, $userName',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 4),

                GestureDetector(
                  onTap: onLocationPressed,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF6680FF),
                        size: 20,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        location,
                        style: const TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(width: 4),

                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF6680FF),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 오른쪽 프로필 이미지
          InkWell(
            onTap: onProfilePressed,
            borderRadius: BorderRadius.circular(24),
            child: CircleAvatar(
              radius: 21,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty ? NetworkImage(profileImageUrl!) : null,
              child: profileImageUrl == null || profileImageUrl!.isEmpty ? const Icon(
                Icons.person,
                color: Colors.grey,
              ) : null,
            ),
          ),
        ],
      ),
    );
  }
}