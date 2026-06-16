import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/auth_controller.dart';

class AdminShellLayout extends ConsumerWidget {
  final Widget child;

  const AdminShellLayout({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final router = GoRouter.of(context);
    final location = router.routerDelegate.currentConfiguration.uri.toString();

    // Check width to decide if desktop sidebar should be shown
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Admin Portal'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
      drawer: isDesktop ? null : _buildDrawer(context, ref, location),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context, ref, location),
          Expanded(
            child: Column(
              children: [
                if (isDesktop) _buildHeader(context, ref, user?.name ?? 'Admin'),
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, String adminName) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Inventory Control Panel',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              Text(
                'Welcome, $adminName',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.admin_panel_settings, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, WidgetRef ref, String currentLocation) {
    return Container(
      width: 260,
      color: const Color(0xFF1E293B), // Dark theme sidebar
      child: Column(
        children: [
          Container(
            height: 70,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: const [
                Icon(Icons.movie_creation_rounded, color: AppColors.primary, size: 28),
                SizedBox(width: 12),
                Text(
                  'BMS Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _SidebarItem(
                  icon: Icons.movie_outlined,
                  label: 'Movies',
                  isSelected: currentLocation.startsWith('/admin/movies'),
                  onTap: () => context.go('/admin/movies'),
                ),
                const SizedBox(height: 8),
                _SidebarItem(
                  icon: Icons.theater_comedy_outlined,
                  label: 'Theaters',
                  isSelected: currentLocation.startsWith('/admin/theaters'),
                  onTap: () => context.go('/admin/theaters'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _SidebarItem(
              icon: Icons.logout_rounded,
              label: 'Logout',
              isSelected: false,
              onTap: () => ref.read(authControllerProvider.notifier).logout(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, String currentLocation) {
    return Drawer(
      child: Container(
        color: const Color(0xFF1E293B),
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0F172A)),
              child: Center(
                child: Text(
                  'BookMyShow Admin',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _SidebarItem(
                    icon: Icons.movie_outlined,
                    label: 'Movies',
                    isSelected: currentLocation.startsWith('/admin/movies'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/admin/movies');
                    },
                  ),
                  const SizedBox(height: 8),
                  _SidebarItem(
                    icon: Icons.theater_comedy_outlined,
                    label: 'Theaters',
                    isSelected: currentLocation.startsWith('/admin/theaters'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/admin/theaters');
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _SidebarItem(
                icon: Icons.logout_rounded,
                label: 'Logout',
                isSelected: false,
                onTap: () => ref.read(authControllerProvider.notifier).logout(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: AppColors.primary.withOpacity(0.5)) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.white70,
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.white70,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
