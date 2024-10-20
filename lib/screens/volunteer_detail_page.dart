import 'dart:convert';

import 'package:child_care_app/service/token.dart';
import 'package:child_care_app/widgets/home_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'volunteer_application_page.dart';

class VolunteerDetailPage extends StatefulWidget {
  final int id;

  const VolunteerDetailPage({required this.id, Key? key}) : super(key: key);

  @override
  _VolunteerDetailPageState createState() => _VolunteerDetailPageState();
}

class _VolunteerDetailPageState extends State<VolunteerDetailPage> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  bool _isScrapped = false;

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    final serverIp = dotenv.env['SERVER_IP'] ?? 'http://defaultIp';
    final accessToken = await getJwtToken();
    final url =
        Uri.parse('$serverIp/get/center/${widget.id}/recruitment/reservation');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _data = responseData;
        _isScrapped = responseData['scrap'] ?? false;
        _isLoading = false;
      });
    } else {
      print('Failed to load data');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleScrap() async {
    final serverIp = dotenv.env['SERVER_IP'] ?? 'http://defaultIp';
    final accessToken = await getJwtToken();
    final url = Uri.parse('$serverIp/api/app/scrap/recruitment/create');
    final data = jsonEncode({"recruitmentId": widget.id});
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: data);
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _isScrapped = !_isScrapped;
      });
    } else {
      // Error handling
      print('Failed to scrap');
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

    if (_data == null) {
      return const Center(child: Text("No data available"));
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0)
            .copyWith(top: 24.0), // Add more space at the top
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _data!['recruitmentName'] ?? 'No Name',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isScrapped ? Icons.bookmark : Icons.bookmark_border,
                    color: _isScrapped ? Colors.blue : null,
                    size: 30,
                  ),
                  onPressed: _toggleScrap,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Divider(height: 1.0, thickness: 1.0, color: Colors.grey),
            const SizedBox(height: 16.0),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 3,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('봉사 기간',
                        '${_data!['recruitmentStartDate']} ~ ${_data!['recruitmentEndDate']}'),
                    const SizedBox(height: 8.0),
                    _buildDetailRow(
                        '봉사 시간',
                        '${_data!['startTime']} ~ ${_data!['endTime']}' ??
                            'N/A'),
                    const SizedBox(height: 8.0),
                    _buildDetailRow('모집 인원', '${_data!['totalApplicants']}'),
                    const Divider(height: 32.0, thickness: 1.0),
                    Expanded(
                      child: Text(
                        _data!['detailInfo'] ?? 'No Description',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VolunteerApplicationPage(
                        volunteerData: _data!,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16269E),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('신청하기',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const HomeBottomNavigationBar(),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
