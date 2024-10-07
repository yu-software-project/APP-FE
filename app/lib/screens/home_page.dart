import 'dart:convert';
import 'dart:io';
import 'package:child_care_app/service/token.dart';
import 'package:child_care_app/widgets/home_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4, // 그림자 추가
        backgroundColor: Colors.white,
        toolbarHeight: 110,
        automaticallyImplyLeading: false,
      ),
      body: Text('hi'),
      bottomNavigationBar: const HomeBottomNavigationBar(),
    );
  }
}
