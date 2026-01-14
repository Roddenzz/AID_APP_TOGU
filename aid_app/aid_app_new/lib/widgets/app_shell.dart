import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'animated_particle_background.dart';

// Re-defining NavItem here for simplicity, or it could be in its own file.
class NavItem {
  final String label;
  final IconData icon;
  NavItem({required this.label, required this.icon});
}

class AppShell extends StatefulWidget {
  final String title;
  final List<Widget> screens;
  final List<NavItem> items;
  final bool isStaff;
  final Function(BuildContext) onLogout;

  const AppShell({
    Key? key,
    required this.title,
    required this.screens,
    required this.items,
    required this.isStaff,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      _fadeController.reverse().then((_) {
        setState(() {
          _selectedIndex = index;
        });
        _fadeController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 900;
        return Container(
          color: AppColors.darkGray, // Solid dark background
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(context),
            body: Stack(
              children: [
                // Subtle particle animation for the background
                Positioned.fill(
                  child: AnimatedParticleBackground(
                    particleCount: 25,
                    particleBaseColor: AppColors.lightViolet,
                  ),
                ),
                // Main content
                isDesktop
                    ? _buildDesktopLayout()
                    : _buildMobileLayout(),
              ],
            ),
            bottomNavigationBar: isDesktop ? null : _buildBottomNavBar(),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.title, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.white.withOpacity(0.1),
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.logout_outlined, color: AppColors.white),
          onPressed: () => widget.onLogout(context),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(
          child: AnimatedFade(
            controller: _fadeController,
            child: widget.screens[_selectedIndex],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return AnimatedFade(
      controller: _fadeController,
      child: widget.screens[_selectedIndex],
    );
  }

  Widget _buildSidebar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: 260,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            border: Border(right: BorderSide(color: AppColors.white.withOpacity(0.1))),
          ),
          child: Column(
            children: [
              // ... Header ...
              const SizedBox(height: 40),
              for (int i = 0; i < widget.items.length; i++)
                _buildSidebarItem(i),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem(int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cyan.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(widget.items[index].icon, color: isSelected ? AppColors.cyan : Colors.white70),
            const SizedBox(width: 16),
            Text(widget.items[index].label, style: TextStyle(color: isSelected ? AppColors.cyan : Colors.white70, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: AppColors.darkViolet.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.white.withOpacity(0.2)),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                  left: (MediaQuery.of(context).size.width - 32) / widget.items.length * _selectedIndex,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 32) / widget.items.length,
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(widget.items.length, (index) {
                    return _buildBottomNavBarItem(index);
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBarItem(int index) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Center(
          child: Icon(
            widget.items[index].icon,
            color: isSelected ? AppColors.cyan : Colors.white70,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class AnimatedFade extends StatelessWidget {
  final Animation<double> controller;
  final Widget child;
  const AnimatedFade({Key? key, required this.controller, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: controller, curve: Curves.easeIn),
      child: child,
    );
  }
}
