import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'baidu_map_plugin_method_channel.dart';

abstract class BaiduMapPluginPlatform extends PlatformInterface {
  /// Constructs a BaiduMapPluginPlatform.
  BaiduMapPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static BaiduMapPluginPlatform _instance = MethodChannelBaiduMapPlugin();

  /// The default instance of [BaiduMapPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelBaiduMapPlugin].
  static BaiduMapPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BaiduMapPluginPlatform] when
  /// they register themselves.
  static set instance(BaiduMapPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
