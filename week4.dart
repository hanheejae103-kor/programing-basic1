import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '4주차 과제 - 위젯 조합 화면',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _likeCount = 0;
  final List<String> _comments = ['첫 번째 방명록입니다!', '반갑습니다!'];
  final TextEditingController _controller = TextEditingController();

  void _addComment() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _comments.add(_controller.text);
        _controller.clear();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 프로필 & 방명록'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 프로필 영역 (Row, Column, Image, Text, Icon 사용)
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    'https://picsum.photos/80',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '홍길동',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.badge, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          'Flutter 개발자 지망생',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 좋아요 동작 버튼 영역 (ElevatedButton, Icon, Text 사용)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _likeCount++;
                    });
                  },
                  icon: const Icon(Icons.thumb_up),
                  label: const Text('좋아요'),
                ),
                Text(
                  '누적 좋아요 수: $_likeCount회',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 32),
            // 방명록 입력 영역
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '방명록을 남겨주세요',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addComment, child: const Text('등록')),
              ],
            ),
            const SizedBox(height: 16),
            // 방명록 목록 영역 (ListView 사용)
            Expanded(
              child: ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.comment),
                      title: Text(_comments[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/*
## 2. 위젯 선택표

| 만들 기능 | 위젯 범주 | 선택한 위젯 | 선택 이유 |
|   :---                                 |   :---           |   :---                   |   :---                                                                       |

| 화면 전체 기본 레이아웃 구성               | 배치 위젯         | Scaffold, AppBar         | 모바일 앱의 표준 상단 바 및 기본 바디 구조를 생성하기 위함                           |

| 사용자 프로필 이미지 및 스킬 아이콘 표시    | 보여 주기 위젯     | Image.network, Icon      | 프로필 사진 레이아웃과 텍스트 옆 부가 아이콘을 시각적으로 전달하기 위함                |

| 사용자 이름 및 방명록 텍스트 출력          | 보여 주기 위젯     | Text                     | 텍스트 정보를 화면에 정확히 표시하기 위함                                          |

| 프로필 수평/수직 배치 및 방명록 리스트 배치 | 배치 위젯          | Row, Column, ListView    | 프로필 정보를 가로/세로로 정렬하고, 가변적인 방명록 목록을 스크롤 가능하게 배치하기 위함 |

| 좋아요 버튼 클릭 및 방명록 등록 이벤트     | 동작 위젯          | ElevatedButton           | 사용자 터치 이벤트를 받아 화면의 상태(_likeCount, _comments)를 업데이트하기 위함     |
*/

/*
## 3. 결정 근거표

| 위젯 명              | 공식 문서 위치 (URL / 섹션)                          | 확인 내용                                                             | 현재 화면에 적용한 이유                                                           |

| :---                | :---                                              | :---                                                                 | :---                                                                           |

| ListView.builder    | flutter.dev/docs/development/ui/widgets/scrolling | 대량 혹은 가변적인 아이템 목록을 효율적으로 렌더링하도록 itemBuilder를 제공함 | 작성된 방명록 개수에 따라 동적으로 리스트가 늘어나고 스크롤이 가능하도록 하기 위함         |

| ElevatedButton.icon | flutter.dev/docs/development/ui/widgets/material  | 입체감 있는 버튼 형태에 icon과 label을 동시에 손쉽게 배치할 수 있음         | '좋아요' 기능을 시각적 아이콘과 텍스트로 명확하게 사용자에게 전달하기 위함                |

| Row / Column        | flutter.dev/docs/development/ui/widgets/layout    | 단일 차원(가로/세로) 축을 기준으로 자식 위젯들을 순서대로 정렬 및 배치함      | 프로필 사진과 정보는 가로(Row), 프로필과 방명록 구역 전체는 세로(Column)로 구조화하기 위함 |
*/
