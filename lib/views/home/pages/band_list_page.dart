import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rockstar_app/services/api/band_service.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/band/band_page.dart';
import 'package:rockstar_app/views/band/pages/create_band_page.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandListPage extends StatefulWidget {
  const BandListPage({super.key});

  @override
  State<BandListPage> createState() => _BandListPageState();
}

class _BandListPageState extends State<BandListPage> {
  List<Map<String, dynamic>> bands = [];
  bool isEmptyList = false;
  bool isManager = false;
  int _currentPage = 0;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getMyBands();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getMyBands() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final response = await BandService.getMyBandList(_currentPage);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      print("밴드 목록 불러오기 성공: $decoded");
      final List content = decoded['content'];
      print("밴드 목록 불러오기 성공: $decoded");
      if (content.isEmpty) {
        setState(() => isEmptyList = true);
      } else {
        setState(() {
          bands.addAll(content.cast<Map<String, dynamic>>());
          _currentPage++;
        });
      }
    } else if (response.statusCode == 401) {
      final retryResponse = await UserService.reissueToken();
      if (retryResponse.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(retryResponse.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', decoded['accessToken']);
        await prefs.setString('refreshToken', decoded['refreshToken']);
        getMyBands(); // 재시도
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => AnimatedStartPage()),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      // TODO: 서버 오류 시 행동
      print("밴드 목록 불러오기 실패: ${jsonDecode(utf8.decode(response.bodyBytes))}");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 30, top: 20),
          child: Align(
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
                    builder: (_) => const CreateBandPage(), // 밴드 생성 페이지
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
        ),
        // const SizedBox(height: 0),
        Expanded(
          child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  bands.clear();
                  _currentPage = 0;
                  isEmptyList = false;
                });
                await getMyBands();
              },
              child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 95),
                  controller: _scrollController,
                  itemCount: bands.length + 1,
                  itemBuilder: (context, index) {
                    if (index < bands.length) {
                      final band = bands[index];
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
                                    builder: (context) => BandPage(
                                        bandId: band['bandId'],
                                        bandName: band['bandName'])),
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
                                    fontSize: 23,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                if (band['isManager'])
                                  Icon(FontAwesomeIcons.crown,
                                      size: 20, color: Colors.amber)
                                // Image.asset(
                                //   'assets/logo/crown.png',
                                //   width: 25,
                                //   height: 25,
                                // ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      if (_isLoading) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else {
                        return const SizedBox.shrink(); // 다음 스크롤까지 대기
                      }
                    }
                  })),
        ),
      ],
    );
  }
}
