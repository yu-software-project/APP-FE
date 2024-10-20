import 'package:child_care_app/screens/map.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Map1DefaultScreen(),
    );
  }
}

class KakaoMapView extends StatelessWidget {
  const KakaoMapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
