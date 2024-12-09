import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'baidu_map_plugin_method_channel.dart';

abstract class BaiduMapPluginPlatform extends PlatformInterface {
  BaiduMapPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static BaiduMapPluginPlatform _instance = BaiduMapPluginMethodChannel();

  /// 获取当前实例
  static BaiduMapPluginPlatform get instance => _instance;

  /// 设置当前实例
  static set instance(BaiduMapPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// 初始化百度地图
  Future<void> initialize(String apiKey);

  /// 创建地图视图
  Widget createMapView();

  /// 设置地图中心点
  Future<void> setCenter(double latitude, double longitude) {
    throw UnimplementedError('setCenter() has not been implemented.');
  }


  /// 添加地图标点
  Future<void> addMarker(double latitude, double longitude);

  /// 移除地图标点
  Future<void> removeMarker(double latitude, double longitude);
}