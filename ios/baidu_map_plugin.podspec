Pod::Spec.new do |s|
  s.name             = 'baidu_map_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for Baidu Map integration.'
  s.description      = <<-DESC
A Flutter plugin to integrate Baidu Map SDK with native iOS and Android platforms.
                       DESC
  s.homepage         = 'https://github.com/xianwen-zhu/baidu_map_plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Xianwen Zhu' => 'fmxianwen@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.resources = 'Assets/**/*'
  s.resource_bundles = {'Image_Picker'=>['Assets/*.png']}
  s.dependency       'Flutter'
  s.platform         = :ios, '12.0' # 根据需求调整为更高版本
  s.dependency       'BaiduMapKit', '~> 6.0'
  s.dependency       'BMKLocationKit', '~> 2.1.2'

  # 确保模块定义并排除不必要的架构
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64'
  }

  s.swift_version = '5.0'
end
