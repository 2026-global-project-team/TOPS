import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tops/services/profile_service.dart';
import 'package:tops/services/profile_stats_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _primaryBlue =
  Color(0xFF6680F5);

  static const Color _lightChartBlue =
  Color(0xFF6680FF);

  static const Color _middleChartBlue =
  Color(0xFF4A5FBC);

  static const Color _darkChartBlue =
  Color(0xFF35468F);

  /*
   * 화면을 처음 열었을 때 잠시 사용할 기본값입니다.
   *
   * 실제 데이터는 initState()에서 _loadProfile()을 호출하여
   * ProfileService를 통해 Supabase에서 가져옵니다.
   */
  String _greetingName = 'TOPS Traveler';
  String _userName = 'TOPS Traveler';
  String _city = 'London';

  String _currentLevel = 'City Wanderer';
  String _nextLevel = 'Local Expert';

  String? _profileImageUrl;

  /*
   * Supabase 통계 데이터
   *
   * Places:
   * 현재 사용자가 방문하거나 기록한 장소 개수
   *
   * Photos:
   * 현재 사용자의 story_images 사진 행 개수
   *
   * Wish:
   * 현재 사용자의 wishlist 행 개수
   */
  int _placeCount = 0;
  int _photoCount = 0;
  int _wishCount = 0;

  double _levelProgress = 0;

  double _cafeRate = 0;
  double _restaurantRate = 0;
  double _cultureRate = 0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfilePage();
  }

  Future<void> _loadProfilePage() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      /*
     * 프로필 기본 정보와 통계는 서로 다른 서비스에서 조회한다.
     *
     * 통계 쿼리에 문제가 생겨도
     * 사용자 이름·위치·프로필 사진 조회는 영향을 받지 않는다.
     */
      final Future<ProfileData> profileFuture =
      ProfileService.getCurrentProfile();

      final Future<ProfileStatsData> statsFuture =
      ProfileStatsService.getCurrentUserStatsSafely();

      final ProfileData profile =
      await profileFuture;

      final ProfileStatsData stats =
      await statsFuture;

      if (!mounted) {
        return;
      }

      setState(() {
        _greetingName = profile.userName;
        _userName = profile.userName;
        _city = profile.location;
        _profileImageUrl =
            profile.profileImageUrl;

        _placeCount = stats.placeCount;
        _photoCount = stats.photoCount;
        _wishCount = stats.wishCount;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'Profile page loading error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to load profile information.',
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadProfilePage,
        child: SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            bottom: 135,
          ),
          child: Column(
            children: [
              _buildTopSection(),
              _buildStatistics(),
              const SizedBox(height: 8),
              _buildMenuSection(),
            ],
          ),
        ),
      ),
    );
  }
  // 여기부터 기존 _buildTopSection() 이하 코드를 그대로 둡니다.
  Widget _buildTopSection() {
    return SizedBox(
      height: 500,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildBlueHeader(),

          Positioned(
            left: 32,
            right: 32,
            top: 272,
            child: _buildImpactCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildBlueHeader() {
    return Container(
      width: double.infinity,
      height: 410,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF5C76F0),
            Color(0xFF7087F7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(46),
          bottomRight: Radius.circular(46),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              Text(
                'Good Morning, $_greetingName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 3),

              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _city,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  _buildProfileImage(),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4B5FBB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _currentLevel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          _userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  const Text(
                    'My Level',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      _currentLevel,
                      style: const TextStyle(
                        color: Color(0xFFE0E5FF),
                        fontSize: 13,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF738AF4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _nextLevel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _levelProgress.clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: const Color(0xFF8FA0EC),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: _profileImageUrl != null &&
            _profileImageUrl!.isNotEmpty
            ? Image.network(
          _profileImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _buildDefaultProfile();
          },
        )
            : Image.asset(
          'assets/images/profile_sample.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _buildDefaultProfile();
          },
        ),
      ),
    );
  }

  Widget _buildDefaultProfile() {
    return Container(
      color: const Color(0xFFE5E6EA),
      alignment: Alignment.center,
      child: const Icon(
        Icons.person,
        color: Color(0xFF96989F),
        size: 37,
      ),
    );
  }

  Widget _buildImpactCard() {
    return Container(
      height: 225,
      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFD5DDFF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Local Impact',
              style: TextStyle(
                color: _primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Contribution by category',
            style: TextStyle(
              color: Color(0xFF777A84),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 125,
                  height: 125,
                  child: CustomPaint(
                    painter: _ImpactChartPainter(
                      cafeRate: _cafeRate,
                      restaurantRate: _restaurantRate,
                      cultureRate: _cultureRate,
                    ),
                  ),
                ),

                const SizedBox(width: 18),

                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(
                      color: _lightChartBlue,
                      text: 'Cafe',
                    ),
                    SizedBox(height: 9),
                    _LegendItem(
                      color: _middleChartBlue,
                      text: 'Restaurant',
                    ),
                    SizedBox(height: 9),
                    _LegendItem(
                      color: _darkChartBlue,
                      text: 'Culture',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        36,
        18,
        36,
        20,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'Places',
              value: _placeCount.toString(),
            ),
          ),

          const _StatDivider(),

          Expanded(
            child: _StatItem(
              label: 'Photos',
              value: _photoCount.toString(),
            ),
          ),

          const _StatDivider(),

          Expanded(
            child: _StatItem(
              label: 'Wish',
              value: _wishCount.toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _ProfileMenuItem(
            icon: Icons.settings,
            label: 'Setting',
            onTap: () {
              _showMessage(
                'Settings page will be connected later.',
              );
            },
          ),

          _ProfileMenuItem(
            icon: Icons.notifications,
            label: 'Notification',
            onTap: () {
              _showMessage(
                'Notifications page will be connected later.',
              );
            },
          ),

          _ProfileMenuItem(
            icon: Icons.logout,
            label: 'Log out',
            onTap: _showLogoutDialog,
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text(
            'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) {
      return;
    }

    // Supabase 로그아웃 연결 시 주석 해제
    /*
    await Supabase.instance.client.auth.signOut();
    */

    _showMessage(
      'Logout will be connected later.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF292929),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF777777),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF111111),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 54,
      color: const Color(0xFFD7D9E1),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFD9DBE2),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFA7A9B0),
              size: 22,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF252525),
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF111111),
              size: 27,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactChartPainter extends CustomPainter {
  final double cafeRate;
  final double restaurantRate;
  final double cultureRate;

  const _ImpactChartPainter({
    required this.cafeRate,
    required this.restaurantRate,
    required this.cultureRate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius =
        math.min(size.width, size.height) / 2;

    const strokeWidth = 30.0;
    const startAngle = -math.pi / 2;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    final rates = [
      cafeRate,
      restaurantRate,
      cultureRate,
    ];

    const colors = [
      Color(0xFF6680FF),
      Color(0xFF4A5FBC),
      Color(0xFF35468F),
    ];

    final total = rates.fold<double>(
      0,
          (sum, value) => sum + value,
    );

    final normalizedRates = total <= 0
        ? <double>[1, 0, 0]
        : rates.map((value) => value / total).toList();

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double currentAngle = startAngle;

    for (int index = 0;
    index < normalizedRates.length;
    index++) {
      final sweepAngle =
          normalizedRates[index] * math.pi * 2;

      paint.color = colors[index];

      canvas.drawArc(
        rect,
        currentAngle,
        sweepAngle,
        false,
        paint,
      );

      currentAngle += sweepAngle;
    }

    canvas.drawCircle(
      center,
      radius - strokeWidth,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(
      covariant _ImpactChartPainter oldDelegate,
      ) {
    return oldDelegate.cafeRate != cafeRate ||
        oldDelegate.restaurantRate != restaurantRate ||
        oldDelegate.cultureRate != cultureRate;
  }
}