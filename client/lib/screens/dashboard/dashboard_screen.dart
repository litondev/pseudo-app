import 'package:flutter/material.dart';
import '../../configs/themes.dart';
import '../../configs/text_styles.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_drawer.dart';
import 'widgets/dashboard_content.dart';

/// Dashboard screen with responsive navigation
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardMenuItem _selectedMenuItem = DashboardMenuItem.dashboard;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        final isMobile = constraints.maxWidth < 768;

        if (isDesktop) {
          return _buildDesktopLayout(context);
        } else if (isTablet) {
          return _buildTabletLayout(context);
        } else {
          return _buildMobileLayout(context);
        }
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          DashboardDrawer(
            selectedMenuItem: _selectedMenuItem,
            onMenuItemSelected: (item) {
              setState(() {
                _selectedMenuItem = item;
              });
            },
            isRail: true,
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                DashboardAppBar(
                  selectedMenuItem: _selectedMenuItem,
                ),
                Expanded(
                  child: DashboardContent(
                    selectedMenuItem: _selectedMenuItem,
                    isDesktop: true,
                    isTablet: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: DashboardAppBar(
          selectedMenuItem: _selectedMenuItem,
        ),
      ),
      drawer: DashboardDrawer(
        selectedMenuItem: _selectedMenuItem,
        onMenuItemSelected: (item) {
          setState(() {
            _selectedMenuItem = item;
          });
          Navigator.of(context).pop(); // Close drawer
        },
        isRail: false,
      ),
      body: DashboardContent(
        selectedMenuItem: _selectedMenuItem,
        isDesktop: false,
        isTablet: true,
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: DashboardAppBar(
          selectedMenuItem: _selectedMenuItem,
        ),
      ),
      drawer: DashboardDrawer(
        selectedMenuItem: _selectedMenuItem,
        onMenuItemSelected: (item) {
          setState(() {
            _selectedMenuItem = item;
          });
          Navigator.of(context).pop(); // Close drawer
        },
        isRail: false,
      ),
      body: DashboardContent(
        selectedMenuItem: _selectedMenuItem,
        isDesktop: false,
        isTablet: false,
      ),
    );
  }
}

/// Dashboard menu item model
class DashboardMenuItem {
  final String title;
  final IconData icon;
  final String route;

  const DashboardMenuItem({
    required this.title,
    required this.icon,
    required this.route,
  });

  static const dashboard = DashboardMenuItem(
    title: 'Dashboard',
    icon: Icons.dashboard,
    route: '/dashboard',
  );

  static const products = DashboardMenuItem(
    title: 'Products',
    icon: Icons.inventory_2,
    route: '/products',
  );

  static const warehouses = DashboardMenuItem(
    title: 'Warehouses',
    icon: Icons.warehouse,
    route: '/warehouses',
  );

  static const transactions = DashboardMenuItem(
    title: 'Transactions',
    icon: Icons.receipt_long,
    route: '/transactions',
  );

  static const analytics = DashboardMenuItem(
    title: 'Analytics',
    icon: Icons.analytics,
    route: '/analytics',
  );

  static const settings = DashboardMenuItem(
    title: 'Settings',
    icon: Icons.settings,
    route: '/settings',
  );

  static const List<DashboardMenuItem> allItems = [
    dashboard,
    products,
    warehouses,
    transactions,
    analytics,
    settings,
  ];
}