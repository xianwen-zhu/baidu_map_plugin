import 'baidu_map_plugin_platform_interface.dart';
import 'package:flutter/widgets.dart';

class BaiduMapPlugin {
  /// 初始化百度地图
  static Future<void> initialize(String apiKey) async {
    await BaiduMapPluginPlatform.instance.initialize(apiKey);
  }

  /// 创建地图视图
  static Widget createMapView() {
    return BaiduMapPluginPlatform.instance.createMapView();
  }

  /// 设置地图中心点
  static Future<void> setCenter(double latitude, double longitude) {
    return BaiduMapPluginPlatform.instance.setCenter(latitude, longitude);
  }



  /// 添加地图标点
  static Future<void> addMarker(double latitude, double longitude) async {
    await BaiduMapPluginPlatform.instance.addMarker(latitude, longitude);
  }

  /// 移除地图标点
  static Future<void> removeMarker(double latitude, double longitude) async {
    await BaiduMapPluginPlatform.instance.removeMarker(latitude, longitude);
  }
}