import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'baidu_map_plugin_platform_interface.dart';

/// An implementation of [BaiduMapPluginPlatform] that uses method channels.
class MethodChannelBaiduMapPlugin extends BaiduMapPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('baidu_map_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
