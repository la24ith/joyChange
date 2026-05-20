// lib/features/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/hero_section.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/offline_indicator.dart';
import '../widgets/post_card.dart';
import '../widgets/skeleton_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final state = context.read<HomeBloc>().state;
      if (state is HomeLoaded && !state.hasReachedMax) {
        final nextPage = (state.posts.length / 20).ceil() + 1;
        context.read<HomeBloc>().add(FetchPostsEvent(page: nextPage));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          String userName = 'مستخدم';
          if (authState is Authenticated) {
            userName = authState.user.name.split(' ').first;
          }

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ✅ AppBar احترافي
              HomeAppBar(userName: userName),

              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),

                    // ✅ Hero Section
                    const HeroSection(),

                    const SizedBox(height: 24),

                    // ✅ Advertisement Banner
                    const AdBanner(),

                    const SizedBox(height: 32),

                    // ✅ Section Title
                    _buildSectionTitle('آخر المنشورات'),

                    const SizedBox(height: 16),

                    // ✅ Offline Indicator
                    if (!_isConnected) const OfflineIndicator(),

                    const SizedBox(height: 8),
                  ]),
                ),
              ),

              // ✅ Posts Section
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading && state.posts.isEmpty) {
                    return SliverToBoxAdapter(
                      child: SkeletonLoader(
                        count: isTablet ? 6 : 4,
                      ),
                    );
                  }

                  if (state is HomeError && state.posts.isEmpty) {
                    return SliverToBoxAdapter(
                      child: EmptyState(
                        message: state.message,
                        onRetry: () {
                          context
                              .read<HomeBloc>()
                              .add(const RefreshPostsEvent());
                        },
                      ),
                    );
                  }

                  if (state is HomeLoaded) {
                    if (state.posts.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: EmptyState(
                          message: 'لا توجد منشورات حالياً',
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: isTablet ? 400 : 500,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == state.posts.length) {
                              if (state.hasReachedMax) {
                                return const SizedBox.shrink();
                              }
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final post = state.posts[index];
                            return PostCard(post: post);
                          },
                          childCount: state.posts.length +
                              (state.hasReachedMax ? 0 : 1),
                        ),
                      ),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              SliverPadding(
                padding: const EdgeInsets.only(bottom: 32),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(height: isTablet ? 40 : 20),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}
