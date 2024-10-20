import 'dart:convert';

import 'package:child_care_app/service/token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FacilityIntroducePage extends StatefulWidget {
  final String type;
  final int id;

  const FacilityIntroducePage({required this.type, required this.id, Key? key})
      : super(key: key);

  @override
  _FacilityIntroducePage createState() => _FacilityIntroducePage();
}

class _FacilityIntroducePage extends State<FacilityIntroducePage> {
  String _content = '';
  bool _isLoading = true;

  @override
  void didUpdateWidget(covariant FacilityIntroducePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    final serverIp = dotenv.env['SERVER_IP'] ?? 'http://defaultIp';
    final accessToken = await getJwtToken();
    final url = Uri.parse('$serverIp/get/center/${widget.id}/facility/info');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    });
    if (response.statusCode == 200) {
      setState(() {
        _content = jsonDecode(utf8.decode(response.bodyBytes));
        _isLoading = false;
      });
    } else {
      // Error handling
      print('Failed to load data');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        _content,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
