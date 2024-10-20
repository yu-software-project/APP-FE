import 'dart:convert';

import 'package:child_care_app/screens/home_page.dart';
import 'package:child_care_app/screens/signup_page.dart';
import 'package:child_care_app/service/token.dart';
import 'package:child_care_app/widgets/success_alert.dart';
import 'package:child_care_app/widgets/warning_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                Image.asset(
                  // 로고
                  'assets/logo.png',
                  width: 261,
                  height: 220,
                ),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  // 로그인 입력
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Your email address',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      filled: true,
                      fillColor: Color.fromARGB(255, 255, 255, 255),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      filled: true,
                      fillColor: Color.fromARGB(255, 255, 255, 255),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                      ),
                    ),
                    obscureText: true, // 비밀번호 입력 가리기
                  ),
                ]),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpPage()),
                      );
                    },
                    child: const Text('회원가입'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final loginDto = jsonEncode({
                      'email': emailController.text,
                      'password': passwordController.text,
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );

                    final res = await sendToServer(loginDto); // 로그인 요청
                    if (res.statusCode == 200 && context.mounted) {
                      final responseData = jsonDecode(res.body);
                      final tokenDto = responseData['accessTokenDto']
                          as Map<String, dynamic>;
                      final token = tokenDto['accessToken'] as String;
                      // JWT 토큰 저장
                      await saveJwtToken(token);

                      successAlert(context, "로그인 성공");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                      );
                    } else {
                      warningAlert(context, "로그인 실패");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 255, 0, 0),
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(60, 8, 60, 8),
                    child: const Text(
                      "로그인",
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<http.Response> sendToServer(Object loginDto) async {
  final serverIp = dotenv.env['SERVER_IP'] ?? 'http://defaultIp';
  final res = await http.post(
    Uri.parse("$serverIp/api/auth/app/signIn"),
    headers: {'Content-Type': 'application/json'},
    body: loginDto,
  );
  print(res.body);
  return res;
}
