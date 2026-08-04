import 'package:flutter/material.dart';
import '../Screen/Explore/pages/explore_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  static const Color _primaryColor = Color(0xFF4A5FD3);

  int _selectedIndex = 1;
  bool _isQuickMenuOpen = false;

  late final AnimationController _menuController;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _menuScaleAnimation;
  late final Animation<double> _menuOpacityAnimation;

  final List<Widget> _pages = const [
    _TemporaryPage(
      title: 'Home',
      icon: Icons.home_outlined,
    ),
    ExplorePage(),
    _TemporaryPage(
      title: 'Archive',
      icon: Icons.bookmark_border,
    ),
    _TemporaryPage(
      title: 'Profile',
      icon: Icons.person_outline,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // + 버튼이 45도 회전하면서 × 모양으로 바뀜
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.125,
    ).animate(
      CurvedAnimation(
        parent: _menuController,
        curve: Curves.easeInOut,
      ),
    );

    _menuScaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _menuController,
        curve: Curves.easeOutBack,
      ),
    );

    _menuOpacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
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
    if (!_isQuickMenuOpen) {
      return;
    }

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
      SnackBar(
        content: Text('$featureName 화면을 준비 중입니다.'),
      ),
    );
  }

  Widget _buildQuickMenuItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: double.infinity,
          height: 72,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMenu() {
    return FadeTransition(
      opacity: _menuOpacityAnimation,
      child: ScaleTransition(
        scale: _menuScaleAnimation,
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 230,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FF),
            borderRadius: BorderRadius.circular(24),
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
                onTap: () {
                  _showComingSoon('Check-In');
                },
              ),
              const Divider(height: 1),
              _buildQuickMenuItem(
                title: 'New Story',
                onTap: () {
                  _showComingSoon('New Story');
                },
              ),
              const Divider(height: 1),
              _buildQuickMenuItem(
                title: 'Add a Spot',
                onTap: () {
                  _showComingSoon('Add a Spot');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  // 가운데 PNG 버튼
  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: _toggleQuickMenu,
      child: RotationTransition(
        turns: _rotationAnimation,
        child: SizedBox(
          width: 78,
          height: 78,
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
        child: BottomAppBar(
          height: 76,
          padding: EdgeInsets.zero,
          color: Colors.black,
          elevation: 20,
          shape: const CircularNotchedRectangle(),
          notchMargin: 7,
          clipBehavior: Clip.antiAlias,
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

              const SizedBox(width: 78),

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
      onTap: () {
        _selectPage(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected
                ? Colors.white
                : const Color(0xFF9B9BA5),
            size: 24,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF9B9BA5),
              fontSize: 11,
              fontWeight: isSelected
                  ? FontWeight.w600
                  : FontWeight.w400,
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
      // body가 하단 바 뒤까지 이어져서 흰 공간이 생기지 않음
      extendBody: true,

      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),

          // 메뉴가 열렸을 때 화면을 살짝 어둡게
          if (_isQuickMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeQuickMenu,
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.12,
                  ),
                ),
              ),
            ),

          // + 버튼 위에 뜨는 빠른 메뉴
          if (_isQuickMenuOpen)
            Positioned(
              bottom: 115,
              child: _buildQuickMenu(),
            ),
        ],
      ),

      // 이 두 항목이 있어야 가운데 홈이 생김
      floatingActionButton: _buildCenterButton(),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: _buildBottomNavigationBar(),
    );
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