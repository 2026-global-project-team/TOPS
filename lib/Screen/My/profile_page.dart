import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'widgets/local_impact_card.dart';
import 'widgets/profile_header_section.dart';
import 'widgets/profile_menu_list.dart';
import 'widgets/profile_stats.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();

      if (!context.mounted) return;

      Navigator.of(context).popUntil(
            (route) => route.isFirst,
      );
    } on AuthException catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '로그아웃 실패: ${error.message}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? {};

    final userName =
        metadata['full_name'] ??
            metadata['name'] ??
            metadata['user_name'] ??
            user?.email?.split('@').first ??
            'User';

    final profileImageUrl =
        metadata['avatar_url'] ??
            metadata['picture'];

    return Scaffold(
      backgroundColor: Colors.white,

      // 하단바는 MainShell에서 관리
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            bottom: 130,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 430,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ProfileHeaderSection(
                      userName: userName,
                      levelName: 'City Wanderer',
                      nextLevelName: 'Local Expert',
                      levelProgress: 0.82,
                      profileImageUrl: profileImageUrl,
                    ),

                    const Positioned(
                      left: 34,
                      right: 34,

                      // 숫자가 작을수록 카드가 더 위로 올라감
                      top: 190,

                      child: LocalImpactCard(),
                    ),
                  ],
                ),
              ),
              const ProfileStats(
                placesCount: 12,
                photosCount: 35,
                wishCount: 4,
              ),

              ProfileMenuList(
                onSettingPressed: () {
                  debugPrint('설정 화면 이동');
                },
                onNotificationPressed: () {
                  debugPrint('알림 화면 이동');
                },
                onLogoutPressed: () {
                  _logout(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}