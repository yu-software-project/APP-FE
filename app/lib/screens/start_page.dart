import 'package:child_care_app/screens/login_page.dart';
import 'package:child_care_app/screens/signup_page.dart';
import 'package:flutter/material.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 180.0),
              const Text(
                "아지트에 오신 것을 환영합니다.\n로그인 후 아래 기능들을 이용해보세요.",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 60.0),
              const Text(
                "전국 돌봄 교실 정보들을 한 눈에",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 18.0),
              const Text(
                "가장 투명한 기관 목록",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 18.0),
              const Text(
                "관심 기관 및 공고는 즐겨찾기",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 150.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 255, 0, 0),
                    backgroundColor:
                        const Color.fromARGB(255, 0, 0, 0), // 텍스트 색을 흰색으로 설정
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(80, 8, 80, 8),
                    child: const Text(
                      "로그인 하기",
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 15),
                    ),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor:
                        const Color.fromARGB(255, 0, 0, 0), // 텍스트 색을 검은색으로 설정
                  ),
                  child: const Text(
                    "회원가입",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
