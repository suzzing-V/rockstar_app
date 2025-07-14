import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rockstar_app/api/band_service.dart';
import 'package:rockstar_app/api/user_service.dart';
import 'package:rockstar_app/page/create_band_page.dart';
import 'package:rockstar_app/page/start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandListPage extends StatefulWidget {
  const BandListPage({super.key});

  @override
  State<BandListPage> createState() => _BandListPageState();
}

class _BandListPageState extends State<BandListPage> {
  List<Map<String, dynamic>> myBands = [];
  bool isEmptyList = false;
  bool isManager = false;

  @override
  void initState() {
    super.initState();
    getMyBands();
  }

  Future<void> getMyBands() async {
    final response = await BandService.getMyBandList();

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
    } else if (response.statusCode == 401) {
      final response = await UserService.reissueToken();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', decoded['accessToken']);
        await prefs.setString('refreshToken', decoded['refreshToken']);

        /// ✅ 토큰 재발급 성공 후 재시도
        final retry = await BandService.getMyBandList();
        if (retry.statusCode != 200) {
          // TODO: 오류 시 행동
        }
      } else if (response.statusCode == 401) {
        // refresh token 만료 시
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AnimatedStartPage(),
          ),
        );
        return;
      } else {
        // TODO: 오류 시 행동
      }
    } else {
      // TODO: 서버 오류 시 행동
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
                              SizedBox(
                                width: 5,
                              ),
                              if (band['isManager'])
                                Icon(FontAwesomeIcons.crown,
                                    size: 23, color: Colors.amber)
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
                                    const CreateBandPage(), // 밴드 생성 페이지
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
