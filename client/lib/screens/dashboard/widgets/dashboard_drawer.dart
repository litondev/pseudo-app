import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../configs/themes.dart';
import '../../../configs/text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../dashboard_screen.dart';

/// Responsive navigation drawer for the dashboard
class DashboardDrawer extends StatelessWidget {
  final DashboardMenuItem selectedMenuItem;
  final Function(DashboardMenuItem) onMenuItemSelected;
  final bool isRail;

  const DashboardDrawer({
    Key? key,
    required this.selectedMenuItem,
    required this.onMenuItemSelected,
    this.isRail = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isRail) {
      return _buildNavigationRail(context);
    } else {
      return _buildDrawer(context);
    }
  }

  Widget _buildNavigationRail(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Pseudo App',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: DashboardMenuItem.allItems.map((item) {
                final isSelected = selectedMenuItem.route == item.route;
                return _buildMenuItem(context, item, isSelected, false);
              }).toList(),
            ),
          ),
          
          const Divider(height: 1),
          
          // User Info
          _buildUserInfo(context, false),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Pseudo App',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: DashboardMenuItem.allItems.map((item) {
                final isSelected = selectedMenuItem.route == item.route;
                return _buildMenuItem(context, item, isSelected, true);
              }).toList(),
            ),
          ),
          
          const Divider(height: 1),
          
          // User Info
          _buildUserInfo(context, true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, DashboardMenuItem item, bool isSelected, bool isDrawer) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDrawer ? 8 : 12,
        vertical: 2,
      ),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
          size: 24,
        ),
        title: Text(
          item.title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () => onMenuItemSelected(item),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, bool isDrawer) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  user?.name?.isNotEmpty == true 
                      ? user!.name![0].toUpperCase()
                      : 'U',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user?.name ?? 'User',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user?.email ?? 'user@example.com',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  await authProvider.signOut();
                },
                icon: const Icon(
                  Icons.logout,
                  size: 20,
                ),
                tooltip: 'Sign Out',
              ),
            ],
          ),
        );
      },
    );
  }
}