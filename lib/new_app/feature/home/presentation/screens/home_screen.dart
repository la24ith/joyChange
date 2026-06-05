// lib/features/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:joy_of_change_v3/new_app/core/widgets/animation_button.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/presentation/widgets/app_drawer.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../ads/presentation/bloc/ads_bloc.dart';
import '../../../ads/presentation/bloc/ads_event.dart';
import '../../../ads/presentation/widgets/ad_carousel.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../post_details/presentation/screens/post_details_screen.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/posts_skeleton.dart';
import '../widgets/post_card.dart';
import '../widgets/offline_indicator.dart';
import '../widgets/home_header.dart';
import '../widgets/ideal_weight_card.dart';
import '../widgets/sync_status.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeBloc _homeBloc;
  late final AdsBloc _adsBloc;
  final ScrollController _scrollController = ScrollController();
  bool _isOffline = false;
  bool _isSyncing = false;
  bool _showIdealWeight = true;

  @override
  void initState() {
    super.initState();
    _homeBloc = getIt<HomeBloc>()..add(FetchPostsEvent(page: 1, limit: 10));
    _adsBloc = getIt<AdsBloc>()..add(LoadActiveAdsEvent());
    _scrollController.addListener(_onScroll);
    _checkConnectivity();
    _setupConnectivityListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _homeBloc.close();
    _adsBloc.close();
    super.dispose();
  }

  void _onScroll() {
    final state = _homeBloc.state;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (state is HomeLoaded && !state.hasReachedMax) {
        _homeBloc.add(FetchMorePostsEvent());
      }
    }

    if (state is HomeLoaded && !state.hasReachedMax) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final threshold = maxScroll * 0.7;

      if (currentScroll >= threshold) {
        _homeBloc.add(const PrefetchPostsEvent());
      }
    }
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = result == ConnectivityResult.none;
    });
  }

  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((result) async {
      final wasOffline = _isOffline;
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });

      if (wasOffline && !_isOffline) {
        setState(() => _isSyncing = true);
        await Future.delayed(const Duration(seconds: 1));
        _homeBloc.add(RefreshPostsEvent());
        _adsBloc.add(LoadActiveAdsEvent());
        setState(() => _isSyncing = false);
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() => _isSyncing = true);
    _homeBloc.add(RefreshPostsEvent());
    _adsBloc.add(LoadActiveAdsEvent());
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isSyncing = false);
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1200) return 4;
    if (width >= 800) return 3;
    if (width >= 550) return 2;
    return 1;
  }

  double _getCardAspectRatio(double width) {
    if (width >= 1200) return 0.75;
    if (width >= 800) return 0.8;
    if (width >= 550) return 0.85;
    return 0.9;
  }

  EdgeInsets _getScreenPadding(double width) {
    if (width >= 1200) return const EdgeInsets.symmetric(horizontal: 32);
    if (width >= 800) return const EdgeInsets.symmetric(horizontal: 24);
    return const EdgeInsets.symmetric(horizontal: 16);
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final crossAxisCount = _getCrossAxisCount(screenWidth);
    final cardAspectRatio = _getCardAspectRatio(screenWidth);
    final horizontalPadding = _getScreenPadding(screenWidth);
    final sectionFontSize = screenWidth >= 800 ? 20.0 : 18.0;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _homeBloc),
        BlocProvider.value(value: _adsBloc),
      ],
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
            title: const Text('الرئيسية'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: AnimatedMenuButton(
              onTap: () {
                scaffoldKey.currentState?.openDrawer();
              },
            )),
        drawer: const AppDrawer(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            String userName = 'مستخدم';
            if (authState is Authenticated) {
              userName = authState.user.name.split(' ').first;
            }

            return RefreshIndicator(
              onRefresh: _refreshData,
              color: AppColors.primary,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: HomeHeader(
                      userName: userName,
                      screenWidth: screenWidth,
                    ),
                  ),

                  if (_isOffline)
                    SliverToBoxAdapter(
                      child: OfflineIndicator(
                        isOffline: _isOffline,
                        screenWidth: screenWidth,
                      ),
                    ),

                  if (_isSyncing)
                    SliverToBoxAdapter(
                      child: SyncStatus(screenWidth: screenWidth),
                    ),

                  // ✅ Advertisement Carousel
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: horizontalPadding,
                      child: const AdCarousel(),
                    ),
                  ),

                  if (_showIdealWeight)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: horizontalPadding,
                        child: IdealWeightCard(
                          onDismiss: () =>
                              setState(() => _showIdealWeight = false),
                        ),
                      ),
                    ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding.left,
                        24,
                        horizontalPadding.right,
                        16,
                      ),
                      child: Text(
                        'أحدث المنشورات',
                        style: TextStyle(
                          fontSize: sectionFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // ✅ Posts section
                  BlocBuilder<HomeBloc, HomeState>(
                    bloc: _homeBloc,
                    builder: (context, state) {
                      if (state is HomeLoading) {
                        return SliverToBoxAdapter(
                          child: PostsSkeleton(count: 5),
                        );
                      }

                      if (state is HomeError && state.existingPosts == null) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: screenWidth >= 800 ? 100 : 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.message,
                                  style: TextStyle(
                                    fontSize: screenWidth >= 800 ? 18 : 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () =>
                                      _homeBloc.add(RefreshPostsEvent()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is HomeLoaded) {
                        if (state.posts.isEmpty) {
                          return SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.article_outlined,
                                    size: screenWidth >= 800 ? 100 : 80,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد منشورات حالياً',
                                    style: TextStyle(
                                      fontSize: screenWidth >= 800 ? 18 : 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return SliverPadding(
                          padding: horizontalPadding,
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: screenWidth >= 800 ? 20 : 16,
                              mainAxisSpacing: screenWidth >= 800 ? 24 : 20,
                              childAspectRatio: cardAspectRatio,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index == state.posts.length) {
                                  if (state.hasReachedMax) {
                                    return const SizedBox.shrink();
                                  }
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ),
                                  );
                                }

                                final post = state.posts[index];
                                return PostCard(
                                  post: post,
                                  screenWidth: screenWidth,
                                  onTap: () {
                                    Get.to(
                                      () => PostDetailsScreen(postId: post.id),
                                    );
                                  },
                                );
                              },
                              childCount: state.posts.length + 1,
                            ),
                          ),
                        );
                      }

                      if (state is HomeError && state.existingPosts != null) {
                        final existingPosts = state.existingPosts!;
                        return SliverPadding(
                          padding: horizontalPadding,
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index == existingPosts.length) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Text(
                                            state.message,
                                            style: const TextStyle(
                                                color: Colors.red),
                                          ),
                                          const SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: () => _homeBloc
                                                .add(FetchMorePostsEvent()),
                                            child: const Text('إعادة المحاولة'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final post = existingPosts[index];
                                return PostCard(
                                  post: post,
                                  screenWidth: screenWidth,
                                  onTap: () {
                                    Get.to(
                                      () => PostDetailsScreen(postId: post.id),
                                    );
                                  },
                                );
                              },
                              childCount: existingPosts.length + 1,
                            ),
                          ),
                        );
                      }

                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(height: screenHeight * 0.05),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
