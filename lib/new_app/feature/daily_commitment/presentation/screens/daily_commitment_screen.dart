import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/presentation/widgets/answer_buttons.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/presentation/widgets/commitment_header.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/presentation/widgets/feedback_message.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/presentation/widgets/question_card.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/presentation/widgets/submission_loader.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/daily_commitment_bloc.dart';
import '../bloc/daily_commitment_event.dart';
import '../bloc/daily_commitment_state.dart';

class DailyCommitmentScreen extends StatelessWidget {
  const DailyCommitmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<DailyCommitmentBloc>()..add(LoadDailyCommitmentEvent()),
      child: const _DailyCommitmentView(),
    );
  }
}

class _DailyCommitmentView extends StatefulWidget {
  const _DailyCommitmentView();

  @override
  State<_DailyCommitmentView> createState() => _DailyCommitmentViewState();
}

class _DailyCommitmentViewState extends State<_DailyCommitmentView> {
  bool _isSubmitting = false;
  bool? _selectedAnswer;
  String? _feedbackMessage;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocListener<DailyCommitmentBloc, DailyCommitmentState>(
        listener: (context, state) {
          if (state is DailyCommitmentSubmitted) {
            setState(() {
              _isSubmitting = false;
              _feedbackMessage = state.message;
            });

            // Auto hide feedback after 3 seconds
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _feedbackMessage = null;
                });
              }
            });
          }

          if (state is DailyCommitmentError) {
            setState(() {
              _isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<DailyCommitmentBloc, DailyCommitmentState>(
          builder: (context, state) {
            if (state is DailyCommitmentLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.teal),
                    SizedBox(height: 16),
                    Text('جاري تحميل السؤال اليومي...'),
                  ],
                ),
              );
            }

            if (state is DailyCommitmentError &&
                state is! DailyCommitmentLoaded) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<DailyCommitmentBloc>()
                            .add(LoadDailyCommitmentEvent());
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state is DailyCommitmentLoaded) {
              final question = state.question;
              final isAnswered = state.answeredToday;

              return SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isTablet ? 600 : 500),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 32 : 20,
                        vertical: isTablet ? 32 : 24,
                      ),
                      child: Column(
                        children: [
                          // Header
                          const CommitmentHeader(),

                          const SizedBox(height: 20),

                          // Main Content
                          Expanded(
                            child: Center(
                              child: AnimationLimiter(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                      AnimationConfiguration.toStaggeredList(
                                    duration: const Duration(milliseconds: 600),
                                    childAnimationBuilder: (widget) =>
                                        SlideAnimation(
                                      verticalOffset: 30,
                                      child: FadeInAnimation(
                                        child: widget,
                                      ),
                                    ),
                                    children: [
                                      // Question Card
                                      if (!isAnswered) ...[
                                        QuestionCard(
                                          isAnswered: false,
                                          questionText: question,
                                        ),
                                        const SizedBox(height: 32),
                                        if (!_isSubmitting)
                                          AnswerButtons(
                                            onYesPressed: () =>
                                                _submitAnswer(context, 'yes'),
                                            onNoPressed: () =>
                                                _submitAnswer(context, 'no'),
                                          ),
                                      ],

                                      if (_isSubmitting)
                                        const SubmissionLoader(),

                                      if (isAnswered) ...[
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 80,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'لقد أجبت على سؤال اليوم',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (state.todayAnswer != null) ...[
                                          const SizedBox(height: 12),
                                          Text(
                                            'إجابتك: ${state.todayAnswer}',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ],

                                      if (_feedbackMessage != null &&
                                          _selectedAnswer != null)
                                        FeedbackMessage(
                                          message: _feedbackMessage!,
                                          isPositive: _selectedAnswer == true,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<void> _submitAnswer(BuildContext context, String answer) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _selectedAnswer = answer == 'yes';
    });

    context.read<DailyCommitmentBloc>().add(
          SubmitAnswerEvent(
            answer: answer,
            date: DateTime.now(),
            notes: null,
          ),
        );
  }
}
