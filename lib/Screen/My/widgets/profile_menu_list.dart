import 'package:flutter/material.dart';

class ProfileMenuList extends StatelessWidget {
  final VoidCallback onSettingPressed;
  final VoidCallback onNotificationPressed;
  final VoidCallback onLogoutPressed;

  const ProfileMenuList({
    super.key,
    required this.onSettingPressed,
    required this.onNotificationPressed,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFF3F3F3),
            width: 8,
          ),
        ),
      ),
      child: Column(
        children: [
          _ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Setting',
            onPressed: onSettingPressed,
          ),

          _ProfileMenuItem(
            icon: Icons.notifications_none,
            title: 'Notification',
            onPressed: onNotificationPressed,
          ),

          _ProfileMenuItem(
            icon: Icons.logout,
            title: 'Log out',
            onPressed: onLogoutPressed,
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 64,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFDADADA),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF303030),
              size: 24,
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF242424),
                  fontSize: 15,
                ),
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Colors.black,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}