import 'package:flutter/material.dart';
import 'package:baidu_map_plugin/baidu_map_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BaiduMapPlugin.initialize("hcPVfqVoYUgEZLpvoEyzWceGGukGaeCT"); // 替换为你的百度地图 API Key
  BaiduMapPlugin.setCenter(40.133952 ,116.594566);
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
  void initState() {
    super.initState();
    // 注册地图事件
    BaiduMapPlugin.onMapLoaded = _onMapLoaded;
    BaiduMapPlugin.onRegionWillChange = _onRegionWillChange;
    BaiduMapPlugin.onRegionDidChange = _onRegionDidChange;
    BaiduMapPlugin.onMapClickedBlank = _onMapClickedBlank;
    BaiduMapPlugin.onMapClickedPoi = _onMapClickedPoi;
    BaiduMapPlugin.onUserLocationUpdated = _onUserLocationUpdated;
    BaiduMapPlugin.onLocationError = _onLocationError;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        BaiduMapPlugin.createMapView(),
        Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            children: [
              FloatingActionButton(
                onPressed: _zoomIn,
                heroTag: "zoomIn",
                child: const Icon(Icons.zoom_in),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                onPressed: _zoomOut,
                heroTag: "zoomOut",
                child: const Icon(Icons.zoom_out),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                onPressed: _moveToUserLocation,
                heroTag: "moveToUserLocation",
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true; // 保持视图状态

  // 地图加载完成
  void _onMapLoaded() {
    debugPrint("地图已加载完成");
  }

  // 地图区域即将变化
  void _onRegionWillChange(bool animated) {
    debugPrint("地图区域即将变化，动画：$animated");
  }

  // 地图区域变化完成
  void _onRegionDidChange(bool animated) {
    debugPrint("地图区域变化完成，动画：$animated");
  }

  // 点击地图空白区域
  void _onMapClickedBlank(double latitude, double longitude) {
    debugPrint("点击了地图空白区域，纬度：$latitude，经度：$longitude");
  }

  // 点击地图 POI
  void _onMapClickedPoi(String name, double latitude, double longitude) {
    debugPrint("点击了地图 POI，名称：$name，纬度：$latitude，经度：$longitude");
  }

  // 用户位置更新
  void _onUserLocationUpdated(double latitude, double longitude) {
    debugPrint("用户位置更新，纬度：$latitude，经度：$longitude");
  }

  // 定位失败
  void _onLocationError(String error) {
    debugPrint("定位失败，错误信息：$error");
  }

  // 放大地图
  void _zoomIn() async {
    try {
      await BaiduMapPlugin.zoomIn();
    } catch (e) {
      debugPrint("放大地图失败: $e");
    }
  }

  // 缩小地图
  void _zoomOut() async {
    try {
      await BaiduMapPlugin.zoomOut();
    } catch (e) {
      debugPrint("缩小地图失败: $e");
    }
  }

  // 回到用户位置
  void _moveToUserLocation() async {
    try {
      await BaiduMapPlugin.moveToUserLocation();
    } catch (e) {
      debugPrint("回到用户位置失败: $e");
    }
  }
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