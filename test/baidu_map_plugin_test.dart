import 'package:flutter_test/flutter_test.dart';
import 'package:baidu_map_plugin/baidu_map_plugin.dart';
import 'package:baidu_map_plugin/baidu_map_plugin_platform_interface.dart';
import 'package:baidu_map_plugin/baidu_map_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBaiduMapPluginPlatform
    with MockPlatformInterfaceMixin
    implements BaiduMapPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BaiduMapPluginPlatform initialPlatform = BaiduMapPluginPlatform.instance;

  test('$MethodChannelBaiduMapPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBaiduMapPlugin>());
  });

  test('getPlatformVersion', () async {
    BaiduMapPlugin baiduMapPlugin = BaiduMapPlugin();
    MockBaiduMapPluginPlatform fakePlatform = MockBaiduMapPluginPlatform();
    BaiduMapPluginPlatform.instance = fakePlatform;

    expect(await baiduMapPlugin.getPlatformVersion(), '42');
  });
}
