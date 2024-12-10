import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'baidu_map_plugin.dart';
import 'baidu_map_plugin_platform_interface.dart';

class BaiduMapPluginMethodChannel extends BaiduMapPluginPlatform {
  static const MethodChannel _channel = MethodChannel('baidu_map_plugin');

  BaiduMapPluginMethodChannel() {
    // 注册原生回调监听
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// 处理来自原生的事件回调
  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onMapLoaded':
        debugPrint("地图加载完成");
        BaiduMapPlugin.onMapLoaded?.call(); // 通知 Dart 层监听器
        break;
      case 'onMapRendered':
        final fullyRendered = call.arguments['fullyRendered'] as bool;
        debugPrint("地图渲染完成: fullyRendered=$fullyRendered");
        BaiduMapPlugin.onMapRendered?.call(fullyRendered);
        break;
      case 'onRegionWillChange':
        final animated = call.arguments['animated'] as bool;
        debugPrint("地图区域即将变化: animated=$animated");
        BaiduMapPlugin.onRegionWillChange?.call(animated);
        break;
      case 'onRegionDidChange':
        final animated = call.arguments['animated'] as bool;
        debugPrint("地图区域变化完成: animated=$animated");
        BaiduMapPlugin.onRegionDidChange?.call(animated);
        break;
      case 'onMapClickedBlank':
        final latitude = call.arguments['latitude'] as double;
        final longitude = call.arguments['longitude'] as double;
        debugPrint("地图空白区域点击: latitude=$latitude, longitude=$longitude");
        BaiduMapPlugin.onMapClickedBlank?.call(latitude, longitude);
        break;
      case 'onMapClickedPoi':
        final name = call.arguments['name'] as String;
        final latitude = call.arguments['latitude'] as double;
        final longitude = call.arguments['longitude'] as double;
        debugPrint(
            "地图POI点击: name=$name, latitude=$latitude, longitude=$longitude");
        BaiduMapPlugin.onMapClickedPoi?.call(name, latitude, longitude);
        break;
      case 'onUserLocationUpdated':
        final latitude = call.arguments['latitude'] as double;
        final longitude = call.arguments['longitude'] as double;
        debugPrint("用户位置更新: latitude=$latitude, longitude=$longitude");
        BaiduMapPlugin.onUserLocationUpdated?.call(latitude, longitude);
        break;
      case 'onLocationError':
        final error = call.arguments['error'] as String;
        debugPrint("定位错误: error=$error");
        BaiduMapPlugin.onLocationError?.call(error);
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'Method ${call.method} is not implemented.',
        );
    }
  }

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
        viewType: 'baidu_map_view',
        // iOS 原生注册的 viewType
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
        surfaceFactory:
            (BuildContext context, PlatformViewController controller) {
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

  // 放大地图
  @override
  Future<void> zoomIn() async {
    try {
      await _channel.invokeMethod('zoomIn', {
        'viewId': 0,
      });
    } catch (e) {
      throw Exception("Failed to zoom in: $e");
    }
  }

  // 缩小地图
  @override
  Future<void> zoomOut() async {
    try {
      await _channel.invokeMethod('zoomOut', {
        'viewId': 0,
      });
    } catch (e) {
      throw Exception("Failed to zoom out: $e");
    }
  }

  // 回到用户所在位置
  @override
  Future<void> moveToUserLocation() async {
    try {
      await _channel.invokeMethod('moveToUserLocation', {
        'viewId': 0,
      });
    } catch (e) {
      throw Exception("Failed to move to user location: $e");
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
