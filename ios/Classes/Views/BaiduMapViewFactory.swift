import Flutter
import UIKit
import BaiduMapAPI_Map

class BaiduMapViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private weak var plugin: BaiduMapPlugin?

    init(messenger: FlutterBinaryMessenger, plugin: BaiduMapPlugin) {
        self.messenger = messenger
        self.plugin = plugin
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let mapView = BaiduMapView(frame: frame)
        plugin?.registerMapView(mapView, viewId: viewId) // 在创建视图时立即注册
        return mapView
    }
}
