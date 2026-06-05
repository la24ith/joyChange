// lib/features/splash/presentation/screens/ideal_weight_splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/presentation/bloc/weight_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/presentation/bloc/weight_event.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/presentation/bloc/weight_state.dart';
import 'package:joy_of_change_v3/new_app/feature/navigation/navigation_screen.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/presentation/screen/ideal_weight_screen.dart';

class IdealWeightSplashScreen extends StatefulWidget {
  const IdealWeightSplashScreen({super.key});

  @override
  State<IdealWeightSplashScreen> createState() =>
      _IdealWeightSplashScreenState();
}

class _IdealWeightSplashScreenState extends State<IdealWeightSplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // الانتظار لمدة 5 ثواني ثم الانتقال للشاشة الرئيسية
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const NavigationScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IdealWeightPage(
      isSplashMode: true, // وضع الشاشة المنبثقة لمدة 5 ثواني
    );
  }
}
