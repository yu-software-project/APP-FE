import 'dart:convert';

import 'package:child_care_app/service/token.dart';
import 'package:child_care_app/widgets/home_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'facility_page.dart';

class FavoriteFacilitiesPage extends StatefulWidget {
  const FavoriteFacilitiesPage({super.key});

  @override
  _FavoriteFacilitiesPageState createState() => _FavoriteFacilitiesPageState();
}

class _FavoriteFacilitiesPageState extends State<FavoriteFacilitiesPage> {
  List<Map<String, dynamic>> _favoriteFacilities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteFacilities();
  }

  Future<void> _fetchFavoriteFacilities() async {
    final serverIp = dotenv.env['SERVER_IP'] ?? 'http://defaultIp';
    final accessToken = await getJwtToken();
    final url = Uri.parse('$serverIp/api/app/like/center/search');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    });
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _favoriteFacilities = data.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } else {
      // Handle error
      print('Failed to load favorite facilities');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(int facilityId) async {
    final serverIp = dotenv.env['SERVER_IP'] ?? 'http://defaultIp';
    final accessToken = await getJwtToken();
    final url = Uri.parse('$serverIp/api/app/like/center/create');
    final data = jsonEncode({"childCenterId": facilityId});
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: data);

    if (response.statusCode == 200) {
      await _fetchFavoriteFacilities();
    } else {
      print('Failed to toggle favorite');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // body의 배경색을 회색으로 변경
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨기기
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/logo.png', // 로고 이미지 경로
              height: 80, // 로고 높이
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '관심 기관',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _favoriteFacilities.length,
                      itemBuilder: (context, index) {
                        final item = _favoriteFacilities[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tileColor: Colors.white,
                          leading: const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/profile.png'), // 프로필 이미지 경로
                          ),
                          title: Text(
                            item['centerName'] ?? 'No Name',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${item['roadAddress']} ${item['detailAddress']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.star, color: Colors.yellow),
                            onPressed: () => _toggleFavorite(item['id']),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FacilityPage(
                                  id: item['id'],
                                  name: item['centerName'] ?? 'No Name',
                                  address:
                                      '${item['roadAddress']} ${item['detailAddress']}',
                                  phone: item['centerPhoneNum'],
                                  isLike: true,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          height: 1,
                          color: Colors.grey,
                          indent: 16,
                          endIndent: 16,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const HomeBottomNavigationBar(),
    );
  }
}
