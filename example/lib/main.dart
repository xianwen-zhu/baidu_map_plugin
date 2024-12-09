import 'package:flutter/material.dart';
import 'package:baidu_map_plugin/baidu_map_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BaiduMapPlugin.initialize("hcPVfqVoYUgEZLpvoEyzWceGGukGaeCT"); // 替换为你的百度地图 API Key
  // BaiduMapPlugin.setCenter(31.391297, 121.123175);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainPage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0; // 当前选中的 Tab 索引

  // 页面列表
  final List<Widget> _pages = [
    const BaiduMapTab(), // 地图页面
    const MyProfileTab(), // 我的页面
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index; // 更新选中的 Tab
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '地图',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

class BaiduMapTab extends StatefulWidget {
  const BaiduMapTab({super.key});

  @override
  State<BaiduMapTab> createState() => _BaiduMapTabState();
}

class _BaiduMapTabState extends State<BaiduMapTab> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: BaiduMapPlugin.createMapView(),
    );
  }

  @override
  bool get wantKeepAlive => true; // 保持视图状态
}

class MyProfileTab extends StatelessWidget {
  const MyProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person, size: 100),
            SizedBox(height: 10),
            Text(
              "我的页面",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}