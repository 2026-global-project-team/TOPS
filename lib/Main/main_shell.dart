import 'package:flutter/material.dart';
import 'package:tops/Screen/My/profile_page.dart';
import '../Screen/Explore/pages/explore_page.dart';
import '../Screen/Home/home_page.dart';
import '../Screen/Archive/archive_page.dart';
import '../Wish/wish_page.dart';

class MainShell extends StatefulWidget {
  final int? index;

  const MainShell({
    super.key,
    this.index,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; //화면 뭐부터 띄울지 1은 Explore 0은 Home
  bool _isQuickMenuOpen = false;

  late final AnimationController _menuController;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _menuScaleAnimation;
  late final Animation<double> _menuOpacityAnimation;

  final List<Widget> _pages = const [
    HomePage(),
    ExplorePage(),
    ArchivePage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();

    final receivedIndex = widget.index;

    if (receivedIndex != null &&
        receivedIndex >= 0 &&
        receivedIndex <= 4) {
      _selectedIndex = receivedIndex;
    } else {
      _selectedIndex = 0;
    }

    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.375,
    ).animate(
      CurvedAnimation(
        parent: _menuController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _menuScaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _menuController,
        curve: Curves.easeOutBack,
      ),
    );

    _menuOpacityAnimation = Tween<double>(
      begin: 0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _menuController,
        curve: Curves.easeOut,
      ),
    );
  }

  void _toggleQuickMenu() {
    setState(() {
      _isQuickMenuOpen = !_isQuickMenuOpen;
    });

    if (_isQuickMenuOpen) {
      _menuController.forward();
    } else {
      _menuController.reverse();
    }
  }

  void _closeQuickMenu() {
    if (!_isQuickMenuOpen) return;

    setState(() {
      _isQuickMenuOpen = false;
    });

    _menuController.reverse();
  }

  void _selectPage(int index) {
    _closeQuickMenu();
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showComingSoon(String featureName) {
    _closeQuickMenu();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$featureName 화면을 준비 중입니다.')),
    );
  }

  Widget _buildQuickMenu() {
    return FadeTransition(
      opacity: _menuOpacityAnimation,
      child: ScaleTransition(
        scale: _menuScaleAnimation,
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 232,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FF),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuickMenuItem(
                title: 'Check-In',
                onTap: () => _showComingSoon('Check-In'),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              _buildQuickMenuItem(
                title: 'New Story',
                onTap: () => _showComingSoon('New Story'),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              _buildQuickMenuItem(
                title: 'Wishlist',
                onTap: () {
                  _closeQuickMenu();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WishPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMenuItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 72,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5B5B61),
            ),
          ),
        ),
      ),
    );
  }

  /// 메탈릭 이미지 에셋 + 회전 애니메이션
  Widget _buildCenterButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleQuickMenu,
      child: Container(
        width: 84,
        height: 84,
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: RotationTransition(
          turns: _rotationAnimation,
          child: Image.asset(
            'assets/images/icon_plus.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: SizedBox(
          height: 104,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // 바텀바 배경 (자연스럽게 우묵하게 파이는 베지어 노치 곡선)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: PhysicalShape(
                  clipper: const _FigmaBottomBarClipper(
                    cornerRadius: 34,
                    notchWidth: 98,
                    notchDepth: 38,
                  ),
                  color: Colors.black,
                  elevation: 12,
                  shadowColor: Colors.black38,
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    height: 78,
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildNavigationItem(
                                  index: 0,
                                  icon: Icons.home_outlined,
                                  selectedIcon: Icons.home,
                                  label: 'Home',
                                ),
                              ),
                              Expanded(
                                child: _buildNavigationItem(
                                  index: 1,
                                  icon: Icons.search,
                                  selectedIcon: Icons.search,
                                  label: 'Explore',
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 중앙 버튼 공간
                        const SizedBox(width: 90),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildNavigationItem(
                                  index: 2,
                                  icon: Icons.bookmark_border,
                                  selectedIcon: Icons.bookmark,
                                  label: 'Archive',
                                ),
                              ),
                              Expanded(
                                child: _buildNavigationItem(
                                  index: 3,
                                  icon: Icons.person_outline,
                                  selectedIcon: Icons.person,
                                  label: 'Profile',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 플로팅 메탈릭 버튼
              Positioned(
                top: 0,
                child: _buildCenterButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectPage(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected ? Colors.white : const Color(0xFF9B9BA5),
            size: 25,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF9B9BA5),
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          if (_isQuickMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeQuickMenu,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.12),
                ),
              ),
            ),
          if (_isQuickMenuOpen)
            Positioned(
              bottom: 138,
              child: _buildQuickMenu(),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}

/// 완벽하게 부드러운 S자 곡선(Smooth Bezier) 노치를 생성하는 커스텀 클리퍼
class _FigmaBottomBarClipper extends CustomClipper<Path> {
  const _FigmaBottomBarClipper({
    required this.cornerRadius,
    required this.notchWidth,
    required this.notchDepth,
  });

  final double cornerRadius;
  final double notchWidth;
  final double notchDepth;

  @override
  Path getClip(Size size) {
    final path = Path();
    final cx = size.width / 2;
    final halfW = notchWidth / 2;

    path.moveTo(cornerRadius, 0);

    // 노치 진입 전 상단 라인
    path.lineTo(cx - halfW, 0);

    // 노치 좌측 내리막 곡선 (부드러운 S자 베지어 곡선)
    path.cubicTo(
      cx - (halfW * 0.62), 0,
      cx - (halfW * 0.42), notchDepth,
      cx, notchDepth,
    );

    // 노치 우측 오르막 곡선 (부드러운 S자 베지어 곡선)
    path.cubicTo(
      cx + (halfW * 0.42), notchDepth,
      cx + (halfW * 0.62), 0,
      cx + halfW, 0,
    );

    // 노치 탈출 후 상단 라인
    path.lineTo(size.width - cornerRadius, 0);

    // 바깥쪽 모서리 곡선 (알약 형태)
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    path.lineTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _FigmaBottomBarClipper oldClipper) {
    return cornerRadius != oldClipper.cornerRadius ||
        notchWidth != oldClipper.notchWidth ||
        notchDepth != oldClipper.notchDepth;
  }
}

class _TemporaryPage extends StatelessWidget {
  const _TemporaryPage({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: const Color(0xFF4A5FD3),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}