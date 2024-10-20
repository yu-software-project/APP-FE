import 'dart:convert';

import 'package:child_care_app/screens/kakao_map_view.dart';
import 'package:child_care_app/service/token.dart';
import 'package:child_care_app/widgets/home_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'facility_page.dart';

class FindFacilityPage extends StatefulWidget {
  const FindFacilityPage({super.key});

  @override
  _FindFacilityPageState createState() => _FindFacilityPageState();
}

class _FindFacilityPageState extends State<FindFacilityPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _facilities = [];

  void _searchFacilities() async {
    final query = _searchController.text;
    final serverIp = dotenv.env['SERVER_IP'] ?? 'http://defaultIp';
    final accessToken = await getJwtToken();
    final url = Uri.parse('$serverIp/api/center/search/app');
    final body = jsonEncode({'findWord': query});

    final response = await http.post(url, body: body, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    });
    if (response.statusCode == 200) {
      setState(() {
        _facilities = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      print('검색 실패: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                const KakaoMapView(),
                Positioned(
                  top: 90,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: '기관명 또는 주소로 검색',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _searchFacilities,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: _facilities.length,
              itemBuilder: (context, index) {
                final facility = _facilities[index];
                return ListTile(
                  title: Text(facility['centerName']),
                  subtitle: Text(facility['roadAddress']),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FacilityPage(
                          id: facility['id'],
                          name: facility['centerName'],
                          address: facility['roadAddress'],
                          phone: facility['phoneNumber'],
                          isLike: facility['like'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const HomeBottomNavigationBar(),
    );
  }
}
