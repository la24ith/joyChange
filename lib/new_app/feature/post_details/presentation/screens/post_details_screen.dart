// lib/features/post_details/presentation/screens/post_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:joy_of_change_v3/new_app/feature/post_details/presentation/widgets/media_gallery.dart';
import 'package:joy_of_change_v3/new_app/feature/post_details/presentation/widgets/premium_app_bar.dart';
import 'package:joy_of_change_v3/new_app/feature/post_details/presentation/widgets/premium_content_section.dart';
import 'package:joy_of_change_v3/new_app/feature/post_details/presentation/widgets/premium_error_state.dart';
import 'package:joy_of_change_v3/new_app/feature/post_details/presentation/widgets/premium_loading_state.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../core/di/service_locator.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../data/datasources/post_remote_ds.dart';
import '../bloc/post_details_bloc.dart';
import '../bloc/post_details_event.dart';
import '../bloc/post_details_state.dart';

class PostDetailsScreen extends StatelessWidget {
  final int postId;
  final String? postSlug;

  const PostDetailsScreen({
    super.key,
    required this.postId,
    this.postSlug,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostDetailsBloc(
        homeRepository: getIt<HomeRepository>(),
        postRemoteDataSource: getIt<PostRemoteDataSource>(),
      )..add(LoadPostDetailsEvent(postId: postId, postSlug: postSlug)),
      child: const _PostDetailsView(),
    );
  }
}

class _PostDetailsView extends StatelessWidget {
  const _PostDetailsView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: BlocBuilder<PostDetailsBloc, PostDetailsState>(
        builder: (context, state) {
          if (state is PostDetailsLoading) {
            return const PremiumLoadingState();
          }

          if (state is PostDetailsError) {
            return PremiumErrorState(
              message: state.message,
              onRetry: () {
                final bloc = context.read<PostDetailsBloc>();
                final postId = bloc.currentPostId;
                if (postId != null) {
                  bloc.add(LoadPostDetailsEvent(postId: postId));
                }
              },
            );
          }

          if (state is PostDetailsLoaded) {
            final post = state.post;
            final media = state.media;

            return CustomScrollView(
              controller: PrimaryScrollController.of(context),
              slivers: [
                // ✅ Premium App Bar
                PremiumAppBar(
                  title: post.title,
                  thumbnailUrl: post.thumbnailUrl,
                  isDark: isDark,
                  isBookmarked: state.isBookmarked,
                  isLiked: state.isLiked,
                  onBookmark: () {
                    context.read<PostDetailsBloc>().add(ToggleBookmarkEvent());
                  },
                  onLike: () {
                    context.read<PostDetailsBloc>().add(ToggleLikeEvent());
                  },
                  onShare: () {
                    // Share post
                  },
                ),

                // ✅ Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32.0 : 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          post.title,
                          style: TextStyle(
                            fontSize: isTablet ? 32 : 26,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Author and Date
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  isDark ? Colors.grey[800] : Colors.grey[200],
                              child: Text(
                                post.author.name.isNotEmpty
                                    ? post.author.name[0].toUpperCase()
                                    : 'م',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.author.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(post.publishedAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white.withOpacity(0.5)
                                          : Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: 14,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.6)
                                        : Colors.black.withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${post.viewCount}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white.withOpacity(0.6)
                                          : Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ✅ Media Gallery
                        if (media.isNotEmpty)
                          VisibilityDetector(
                            key: const Key('media_gallery'),
                            onVisibilityChanged: (info) {
                              if (info.visibleFraction > 0.5) {
                                // Media gallery is visible
                              }
                            },
                            child: PremiumMediaGallery(
                              media: media,
                              screenWidth: screenWidth,
                            ),
                          ),

                        const SizedBox(height: 24),

                        // ✅ Content
                        PremiumContentSection(
                          content: post.content,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
