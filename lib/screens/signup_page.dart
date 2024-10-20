import 'dart:convert';

import 'package:child_care_app/widgets/success_alert.dart';
import 'package:child_care_app/widgets/warning_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final birthController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordCheckController = TextEditingController();
  bool? _gender; // true for 남, false for 여

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffFAFDFB),
        leading: Tooltip(
          message: 'Back',
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => {Navigator.pop(context)}, // 눌렀을 때 이벤트
            color: Colors.black, // 버튼 색
          ),
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              children: [
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  // 로그인 입력
                  const SizedBox(height: 60.0),
                  Row(
                    children: [
                      Flexible(
                        flex: 3,
                        child: TextFormField(
                          controller: nameController,
                          decoration: getInputDecoration(labelText: '이름'),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Flexible(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.zero, // Container의 패딩을 줄임
                          height: 56, // Container의 높이를 줄임
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1.0),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('남'),
                                  selected: _gender == true,
                                  selectedColor: Colors.black,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _gender = selected ? true : null;
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: _gender == true
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2.0,
                                      horizontal: 12.0), // ChoiceChip의 패딩 조정
                                ),
                              ),
                              const Text("|",
                                  style: TextStyle(color: Colors.black)),
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('여'),
                                  selected: _gender == false,
                                  selectedColor: Colors.black,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _gender = selected ? false : null;
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: _gender == false
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2.0,
                                      horizontal: 12.0), // ChoiceChip의 패딩 조정
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: birthController,
                    decoration: getInputDecoration(labelText: '생년월일 6자리'),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: phoneController,
                    decoration: getInputDecoration(labelText: '전화번호'),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: emailController,
                    decoration: getInputDecoration(labelText: '이메일'),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: passwordController,
                    decoration: getInputDecoration(labelText: '비밀번호'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: passwordCheckController,
                    decoration: getInputDecoration(labelText: '비밀번호 재입력'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 35),
                ]),
                ElevatedButton(
                  onPressed: () async {
                    // 비밀번호 일치 확인
                    if (passwordController.text !=
                        passwordCheckController.text) {
                      warningAlert(context, "비밀번호와 비밀번호 확인이 일치하지 않습니다.");
                      return;
                    }

                    final signupDto = jsonEncode({
                      // signup DTO 생성
                      'name': nameController.text,
                      'gender': _gender,
                      'birth': birthController.text,
                      'emailId': emailController.text,
                      'phoneNum': phoneController.text,
                      'password': passwordController.text,
                      'passwordCheck': passwordCheckController.text,
                    });

                    print(signupDto);

                    final res = await sendToServer(signupDto); // 로그인 요청
                    if (res == 200 && context.mounted) {
                      Navigator.pop(context);
                      successAlert(context, "회원가입이 정상적으로 완료되었습니다.");
                    } else {
                      warningAlert(context, "회원가입 실패");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // 배경 색상을 검은색으로 설정
                    minimumSize: Size(MediaQuery.of(context).size.width * 0.6,
                        35), // 가로 길이를 늘림
                  ),
                  child: const Text(
                    "회원가입",
                    style: TextStyle(
                        color: Colors.white, fontSize: 15), // 텍스트 색상을 흰색으로 설정
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

Future<int> sendToServer(Object signupDto) async {
  final serverIp = dotenv.env['SERVER_IP'] ?? 'http://defaultIp';
  final res = await http.post(
    Uri.parse("$serverIp/api/auth/app/signUp"),
    headers: {'Content-Type': 'application/json'},
    body: signupDto,
  );

  return res.statusCode;
}

InputDecoration getInputDecoration({required String labelText}) {
  return InputDecoration(
    labelText: labelText,
    hintText: "Input your $labelText",
    labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
    filled: true,
    fillColor: const Color.fromARGB(255, 255, 255, 255),
    border: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width: 2.0),
    ),
    contentPadding: const EdgeInsets.symmetric(
        vertical: 16.0, horizontal: 12.0), // 입력칸의 세로 길이를 줄임
  );
}
