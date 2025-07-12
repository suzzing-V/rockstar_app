import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rockstar_app/api/api_call.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandListPage extends StatefulWidget {
  const BandListPage({super.key});

  @override
  State<BandListPage> createState() => _BandListPageState();
}

class _BandListPageState extends State<BandListPage> {
  List<Map<String, dynamic>> myBands = [];
  bool isEmptyList = false;

  @override
  void initState() {
    super.initState();
    fetchMyBands();
  }

  Future<void> fetchMyBands() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    final url = Uri.parse("http://${ApiCall.host}/api/v0/band/user");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(utf8.decode(response.bodyBytes));
      print("밴드 목록 불러오기 성공: $decoded");
      if (decoded.isEmpty) {
        setState(() {
          isEmptyList = true;
        });
      }
      setState(() {
        myBands = decoded.cast<Map<String, dynamic>>();
      });
      // TODO: 토큰 재발급 구현
      // } else if (response.statusCode == 401) {
      //   // final refreshTokenUrl = Uri.parse("http://${ApiCall.host}/api/v0/band/user");
      //   // final refreshResponse = await http.get(
      //   // url,
      //   headers: {
      //     'Authorization': 'Bearer $accessToken',
      //   },
      // );
    } else {
      print("밴드 목록 불러오기 실패: ${jsonDecode(utf8.decode(response.bodyBytes))}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        if (!isEmptyList)
          Expanded(
            child: ListView.builder(
                itemCount: myBands.length + 1,
                itemBuilder: (context, index) {
                  if (index < myBands.length) {
                    final band = myBands[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Align(
                        alignment: Alignment.center,
                        child: FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withOpacity(0.8),
                            minimumSize: Size(350, 80), // 버튼 자체 크기
                            maximumSize: Size(350, 80),
                            textStyle: TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Placeholder()), // 밴드 상세 페이지
                            );
                          },
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.start, // ✅ 왼쪽 정렬
                            children: [
                              Text(
                                band['bandName'],
                                style: TextStyle(
                                  fontFamily: 'PixelFont',
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Column(children: [
                      Align(
                        alignment: Alignment.center,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(300, 60),
                            maximumSize: Size(300, 60),
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer
                                  .withOpacity(0.8),
                              width: 3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const Placeholder(), // 밴드 생성 페이지
                              ),
                            );
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.add,
                              color: Theme.of(context).colorScheme.primaryFixed,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ]);
                  }
                }),
          ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
