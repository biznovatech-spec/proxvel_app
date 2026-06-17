import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/announcement_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/recommendation_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/announcements/announcement_modal.dart';
import '../../models/announcement_model.dart';
import 'widgets/home_header.dart';
import 'widgets/home_explore_content.dart';
import 'widgets/home_for_you_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _startModalShown = false;
  AnnouncementModel? _startAnnouncement;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().loadDestinations();
      context.read<RecommendationController>().loadRecommendations();
      _maybeShowStartAnnouncement();
    });
  }

  /// Carga el anuncio de inicio (placement 'app_start') y lo muestra como
  /// overlay una sola vez por sesión. Falla suave: si no hay anuncio, no hace
  /// nada. Se muestra como overlay (no como ruta de diálogo) para sobrevivir a
  /// los refrescos de GoRouter durante la verificación de sesión.
  Future<void> _maybeShowStartAnnouncement() async {
    if (_startModalShown) return;
    final annCtrl = context.read<AnnouncementController>();
    await annCtrl.load(placement: 'app_start');
    if (!mounted || _startModalShown) return;
    final ann = annCtrl.currentFor('app_start');
    if (ann == null) return;
    _startModalShown = true;
    setState(() => _startAnnouncement = ann);
  }

  void _dismissStartAnnouncement() {
    final ann = _startAnnouncement;
    if (ann == null) return;
    context.read<AnnouncementController>().dismiss(ann.id);
    setState(() => _startAnnouncement = null);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dark status bar icons on the dark header
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final authController = context.watch<AuthController>();
    final userName = authController.currentUser?.fullName ?? 'Viajero';

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Container(
              color: AppColors.background,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(child: HomeHeader(userName: userName)),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyTabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorColor: AppColors.accent,
                          indicatorWeight: 3,
                          labelColor: AppColors.textOnDark,
                          unselectedLabelColor: AppColors.textOnDarkMuted,
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          tabs: const [
                            Tab(text: 'Explorar'),
                            Tab(text: 'Para ti'),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    HomeExploreContent(
                      onSwitchToForYou: () => _tabController.animateTo(1),
                    ),
                    const HomeForYouContent(),
                  ],
                ),
              ),
            ),
          ),
          // Overlay del anuncio de inicio (sobre todo el contenido del home).
          if (_startAnnouncement != null)
            AnnouncementModalOverlay(
              announcement: _startAnnouncement!,
              onClose: _dismissStartAnnouncement,
            ),
        ],
      ),
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
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
