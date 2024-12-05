
import 'baidu_map_plugin_platform_interface.dart';

class BaiduMapPlugin {
  Future<String?> getPlatformVersion() {
    return BaiduMapPluginPlatform.instance.getPlatformVersion();
  }
}
