import 'dart:async';

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

  /// 放大地图
  static Future<void> zoomIn() async {
    await BaiduMapPluginPlatform.instance.zoomIn();
  }

  /// 缩小地图
  static Future<void> zoomOut() async {
    await BaiduMapPluginPlatform.instance.zoomOut();
  }

  /// 回到用户所在位置
  static Future<void> moveToUserLocation() async {
    await BaiduMapPluginPlatform.instance.moveToUserLocation();
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

  // ------------------ 生命周期事件回调 ------------------

  /// 地图加载完成回调
  static VoidCallback? onMapLoaded;

  /// 地图渲染完成回调
  static ValueChanged<bool>? onMapRendered;

  /// 地图区域即将改变回调
  static ValueChanged<bool>? onRegionWillChange;

  /// 地图区域改变完成回调
  static ValueChanged<bool>? onRegionDidChange;

  /// 地图空白区域点击回调
  static void Function(double latitude, double longitude)? onMapClickedBlank;

  /// 地图 POI 点击回调
  static void Function(String name, double latitude, double longitude)? onMapClickedPoi;

  /// 用户位置更新回调
  static void Function(double latitude, double longitude)? onUserLocationUpdated;

  /// 定位错误回调
  static ValueChanged<String>? onLocationError;






}


