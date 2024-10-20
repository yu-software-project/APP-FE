import 'dart:convert';

import 'package:child_care_app/service/token.dart';
import 'package:child_care_app/widgets/home_bottom_navigation_bar.dart';
import 'package:child_care_app/widgets/success_alert.dart';
import 'package:child_care_app/widgets/warning_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class VolunteerApplicationPage extends StatefulWidget {
  final Map<String, dynamic> volunteerData;

  const VolunteerApplicationPage({required this.volunteerData, Key? key})
      : super(key: key);

  @override
  _VolunteerApplicationPageState createState() =>
      _VolunteerApplicationPageState();
}

class _VolunteerApplicationPageState extends State<VolunteerApplicationPage> {
  DateTime? selectedDate;
  List<DateTime> availableDates = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableDates();
  }

  void _loadAvailableDates() {
    final List<String>? dateStrings =
        widget.volunteerData['recruitmentDates']?.cast<String>();
    if (dateStrings != null) {
      availableDates = dateStrings.map((date) => DateTime.parse(date)).toList();
    } else {
      availableDates = [];
    }
    print(dateStrings);
  }

  Future<void> _selectDate(BuildContext context) async {
    if (availableDates.isEmpty) return;

    final DateTime initialDate = availableDates.first;
    final DateTime firstDate = availableDates.first;
    final DateTime lastDate = availableDates.last;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: (DateTime date) {
        return availableDates.contains(date);
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _submitApplication() async {
    if (selectedDate == null) return;

    final serverIp = dotenv.env['SERVER_IP'] ?? 'http://defaultIp';
    final accessToken = await getJwtToken();
    final url = Uri.parse('$serverIp/api/app/recruitment/waiting/request');
    final data = jsonEncode({
      "recruitmentDates": [selectedDate!.toIso8601String().split('T').first],
      "recruitmentId": widget.volunteerData['id'],
    });
    print(data);
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: data);
    if (response.statusCode == 200) {
      if (mounted) {
        Navigator.pop(context); // 현재 페이지 pop
        successAlert(context, "신청이 완료되었습니다!");
      }
    } else {
      // Handle error response
      warningAlert(context, "이미 신청한 봉사 공고입니다!");
      print('Failed to submit application');
    }
  }

  @override
  Widget build(BuildContext context) {
    final volunteerData = widget.volunteerData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('봉사 신청'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              volunteerData['recruitmentName'] ?? 'No Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('봉사 기관', '어린이 천국 메이커스'),
                    _buildDetailRow(
                        '봉사 기간',
                        '${volunteerData['recruitmentStartDate']} ~ '
                            '${volunteerData['recruitmentEndDate']}'),
                    _buildDetailRow(
                        '봉사 시간',
                        '${volunteerData['startTime']} ~ '
                            '${volunteerData['endTime']}'),
                    _buildDetailRow(
                        '모집 인원', '${volunteerData['totalApplicants']}명'),
                    _buildDetailRow(
                      '봉사 날짜',
                      selectedDate != null
                          ? '${selectedDate!.year}. ${selectedDate!.month}. ${selectedDate!.day}.'
                          : 'YYYY. MM. DD.',
                      trailing: TextButton(
                        onPressed: () => _selectDate(context),
                        child: const Text('날짜 선택'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('신청 취소',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedDate != null ? _submitApplication : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16269E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
          ],
        ),
      ),
      bottomNavigationBar: const HomeBottomNavigationBar(),
    );
  }

  Widget _buildDetailRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
