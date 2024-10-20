import 'dart:convert';

import 'package:child_care_app/screens/volunteer_detail_page.dart';
import 'package:child_care_app/service/token.dart';
import 'package:child_care_app/widgets/home_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ScrapRecruitmentPage extends StatefulWidget {
  const ScrapRecruitmentPage({super.key});

  @override
  _ScrapRecruitmentPageState createState() => _ScrapRecruitmentPageState();
}

class _ScrapRecruitmentPageState extends State<ScrapRecruitmentPage> {
  List<Map<String, dynamic>> _scrapResults = [];

  @override
  void initState() {
    super.initState();
    _fetchScrapRecruitments();
  }

  Future<void> _fetchScrapRecruitments() async {
    final serverIp = dotenv.env['SERVER_IP'] ?? 'http://defaultIp';
    final accessToken = await getJwtToken();
    final url = Uri.parse('$serverIp/api/app/scrap/recruitment/get');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    });
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _scrapResults = data.cast<Map<String, dynamic>>();
      });
    } else {
      print('Failed to load scrap recruitments');
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '스크랩 공고',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _scrapResults.isEmpty
                  ? const Center(child: Text('스크랩된 공고가 없습니다.'))
                  : ListView.builder(
                      itemCount: _scrapResults.length,
                      itemBuilder: (context, index) {
                        final item = _scrapResults[index];
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
                            title: Text(
                              item['recruitmentName'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4.0),
                                Row(
                                  children: [
                                    Text(
                                      '${item['recruitmentStartDate']}',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(width: 30.0),
                                    Text(
                                      item['childCenterName'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.bookmark,
                              color: item['scrap'] ? Colors.blue : Colors.grey,
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
