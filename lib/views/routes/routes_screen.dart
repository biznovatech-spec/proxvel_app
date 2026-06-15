import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/route_model.dart';
import '../../controllers/routes_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/states/loading_view.dart';
import '../../core/widgets/states/proxvel_empty_state.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutesController>().loadRoutes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final controller = context.watch<RoutesController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _buildHeader(controller.routes.length),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.accent,
                  indicatorWeight: 3,
                  labelColor: AppColors.textOnDark,
                  unselectedLabelColor: AppColors.textOnDarkMuted,
                  labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(text: 'Todas'),
                    Tab(text: 'Activas'),
                    Tab(text: 'Completas'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: controller.isLoading
            ? const LoadingView()
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildRoutesView(controller, controller.routes),
                  _buildRoutesView(controller, controller.routes.where((r) => !r.isCompleted).toList()),
                  _buildRoutesView(controller, controller.routes.where((r) => r.isCompleted).toList()),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mis Rutas',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textOnDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      count > 0
                          ? '$count ruta${count > 1 ? 's' : ''} creada${count > 1 ? 's' : ''}'
                          : 'Planifica tu aventura',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textOnDark.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.map_rounded,
                    color: AppColors.accent, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutesView(RoutesController controller, List<RouteModel> list) {
    return ProxvelEmptyState(
      icon: Icons.map_outlined,
      title: 'Próximamente',
      subtitle: 'Estamos preparando rutas turísticas personalizadas para futuras versiones.',
      actionLabel: 'Explorar destinos',
      onAction: () {
        context.go('/home');
      },
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
