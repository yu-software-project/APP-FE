import 'dart:convert';

import 'package:child_care_app/screens/volunteer_detail_page.dart';
import 'package:child_care_app/service/token.dart';
import 'package:child_care_app/widgets/home_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FindVolunteerPage extends StatefulWidget {
  const FindVolunteerPage({super.key});

  @override
  _FindVolunteerPageState createState() => _FindVolunteerPageState();
}

class _FindVolunteerPageState extends State<FindVolunteerPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  Future<void> _searchVolunteer() async {
    final data = jsonEncode({'findWord': _searchController.text});
    final serverIp = dotenv.env['SERVER_IP'] ?? 'http://defaultIp';
    final accessToken = await getJwtToken();
    final url = Uri.parse('$serverIp/api/app/scrap/recruitment/search');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: data);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      print(data);
      setState(() {
        _searchResults = data.cast<Map<String, dynamic>>();
      });
    } else {
      // Handle error
      print('Failed to load search results');
    }
  }

  Future<void> _toggleScrap(int recruitmentId, bool isScrapped) async {
    final serverIp = dotenv.env['SERVER_IP'] ?? 'http://defaultIp';
    final accessToken = await getJwtToken();
    final url = Uri.parse('$serverIp/api/app/scrap/recruitment/create');
    final data = jsonEncode({"recruitmentId": recruitmentId});
    print(data);
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: data);

    if (response.statusCode == 200) {
      setState(() {
        _searchResults = _searchResults.map((item) {
          if (item['id'] == recruitmentId) {
            return {...item, 'scrap': !isScrapped};
          }
          return item;
        }).toList();
      });
    } else {
      print('Failed to toggle scrap');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        toolbarHeight: 100.0,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 40),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/logo.png',
              height: 100.0,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 0.6,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '기관명 또는 지역명으로 검색',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchVolunteer,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onSubmitted: (value) => _searchVolunteer(),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _searchResults.isEmpty
                  ? const Center(child: Text('검색 결과가 없습니다.'))
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 3,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VolunteerDetailPage(id: item['id']),
                                ),
                              );
                            },
                            title: Text(item['recruitmentName']),
                            subtitle: Text('${item['recruitmentStartDate']} '),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.bookmark,
                                color:
                                    item['scrap'] ? Colors.blue : Colors.grey,
                              ),
                              onPressed: () =>
                                  _toggleScrap(item['id'], item['scrap']),
                            ),
                          ),
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
