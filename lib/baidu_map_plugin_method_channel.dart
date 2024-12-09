import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'baidu_map_plugin_platform_interface.dart';

class BaiduMapPluginMethodChannel extends BaiduMapPluginPlatform {
  static const MethodChannel _channel = MethodChannel('baidu_map_plugin');

  /// 初始化百度地图
  @override
  Future<void> initialize(String apiKey) async {
    try {
      await _channel.invokeMethod('initialize', {'apiKey': apiKey});
    } catch (e) {
      throw Exception("Failed to initialize Baidu Map: $e");
    }
  }

  /// 创建地图视图
  @override
  Widget createMapView() {
    if (Platform.isIOS) {
      // iOS 使用 UiKitView
      return UiKitView(
        viewType: 'baidu_map_view', // iOS 原生注册的 viewType
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
        },
        creationParams: <String, dynamic>{
         // 'apiKey': apiKey, // 动态传递 API Key
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (int id) {
          debugPrint('iOS PlatformView created with ID: $id');
        },
      );
    } else if (Platform.isAndroid) {
      // Android 使用 PlatformViewLink
      return PlatformViewLink(
        viewType: 'baidu_map_view', // Android 原生注册的 viewType
        surfaceFactory: (BuildContext context, PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
              //Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()), // 支持所有手势
            },
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: 'baidu_map_view',
            layoutDirection: TextDirection.ltr,
            creationParams: <String, dynamic>{
             // 'apiKey': apiKey, // 动态传递 API Key
            },
            creationParamsCodec: const StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener((int id) {
              params.onPlatformViewCreated(id);
              debugPrint('Android PlatformView created with ID: $id');
            })
            ..create();
        },
      );
    } else {
      // 其他平台不支持
      return Center(
        child: Text('当前平台不支持 Baidu Map'),
      );
    }
  }

  /// 设置地图中心点
  @override
  Future<void> setCenter(double latitude, double longitude) async {
    try {
      await _channel.invokeMethod('setCenter', {
        'latitude': latitude,
        'longitude': longitude,
        'viewId': 0,
      });
    } catch (e) {
      debugPrint("Error during setCenter: $e");
    }
  }

  /// 添加地图标点
  @override
  Future<void> addMarker(double latitude, double longitude) async {
    try {
      await _channel.invokeMethod('addMarker', {
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      throw Exception("Failed to add marker: $e");
    }
  }

  /// 移除地图标点
  @override
  Future<void> removeMarker(double latitude, double longitude) async {
    try {
      await _channel.invokeMethod('removeMarker', {
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      throw Exception("Failed to remove marker: $e");
    }
  }
}