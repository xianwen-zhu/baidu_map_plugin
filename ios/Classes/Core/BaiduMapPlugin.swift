import Flutter
import UIKit
import BaiduMapAPI_Base
import BaiduMapAPI_Map


public class BaiduMapPlugin: NSObject, FlutterPlugin {
    private var mapManager: BMKMapManager?
    private var mapViews: [Int64: BaiduMapView] = [:] // 保存地图实例
    private var pendingTasks: [Int64: [(BaiduMapView) -> Void]] = [:] // 延迟任务队列
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "baidu_map_plugin", binaryMessenger: registrar.messenger())
        let instance = BaiduMapPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // 注册 PlatformView 工厂，用于创建地图视图
        registrar.register(BaiduMapViewFactory(messenger: registrar.messenger(), plugin: instance), withId: "baidu_map_view")
        
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case MethodNames.initialize:
            initializeBaiduMap(call, result: result)
        case MethodNames.setCenter:
            guard let args = call.arguments as? [String: Any],
                  let viewId = (args["viewId"] as? NSNumber)?.int64Value else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "viewId is missing", details: nil))
                return
            }
            if let mapView = mapViews[viewId] {
                // mapView 已初始化，直接执行
                MapCenterManager.shared.setCenter(call, mapView: mapView, result: result)
            } else {
                // mapView 未初始化，将任务添加到延迟队列
                addPendingTask(for: viewId) { [weak self] mapView in
                    MapCenterManager.shared.setCenter(call, mapView: mapView, result: result)
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initializeBaiduMap(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let apiKey = args["apiKey"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "API Key is missing", details: nil))
            return
        }
        // 持久化 API Key 
            UserDefaults.standard.set(apiKey, forKey: "BaiduMapAPIKey")
            
        mapManager = BMKMapManager()
        let success = mapManager?.start(apiKey, generalDelegate: nil) ?? false
        result(success ? nil : FlutterError(code: "INIT_FAILED", message: "Baidu Map Init Failed", details: nil))
    }
    
    func registerMapView(_ mapView: BaiduMapView, viewId: Int64) {
        // 注册 mapView
        mapViews[viewId] = mapView
        
        // 自动开始定位，设置中心点
        DispatchQueue.main.async {
            mapView.setCenter(latitude: 0, longitude: 0) // 可以预设置一个默认值
        }
        
        
        // 执行延迟队列中的任务
        if let tasks = pendingTasks[viewId] {
            for task in tasks {
                task(mapView)
            }
            pendingTasks.removeValue(forKey: viewId)
        }
    }
    
    func unregisterMapView(viewId: Int64) {
        mapViews.removeValue(forKey: viewId)
    }
    
    private func addPendingTask(for viewId: Int64, task: @escaping (BaiduMapView) -> Void) {
        if pendingTasks[viewId] != nil {
            pendingTasks[viewId]?.append(task)
        } else {
            pendingTasks[viewId] = [task]
        }
    }
}