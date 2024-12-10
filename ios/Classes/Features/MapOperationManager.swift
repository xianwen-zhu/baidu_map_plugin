//
//  MapOperationManager.swift
//  baidu_map_plugin
//
//  Created by 朱先文 on 2024/12/6.
//
import Flutter
import BaiduMapAPI_Map

class MapOperationManager {
    static let shared = MapOperationManager()

    /// 设置地图中心点
    func setCenter(_ call: FlutterMethodCall, mapView: BaiduMapView, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let latitude = args["latitude"] as? Double,
              let longitude = args["longitude"] as? Double else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid center coordinates", details: nil))
            return
        }

        DispatchQueue.main.async {
            mapView.setCenter(latitude: latitude, longitude: longitude)
            result(nil)
        }
    }

    /// 放大地图
    func zoomIn(_ mapView: BaiduMapView, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            mapView.zoomLevel += 1
            result(nil)
        }
    }

    /// 缩小地图
    func zoomOut(_ mapView: BaiduMapView, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            mapView.zoomLevel -= 1
            result(nil)
        }
    }
    /// 移动到用户当前位置
    func moveToUserLocation(_ mapView: BaiduMapView, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            if let currentLocation = mapView.getCurrentLocation() {
                print("用户当前位置：纬度 \(currentLocation.latitude)，经度 \(currentLocation.longitude)")
                mapView.setCenter(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
            } else {
                print("用户当前位置不可用")
            }
            
            result(nil)
        }
    }
//
//    /// 添加地图标点
//    func addMarker(_ call: FlutterMethodCall, mapView: BaiduMapView, result: @escaping FlutterResult) {
//        guard let args = call.arguments as? [String: Any],
//              let latitude = args["latitude"] as? Double,
//              let longitude = args["longitude"] as? Double else {
//            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid marker coordinates", details: nil))
//            return
//        }
//
//        DispatchQueue.main.async {
//            let marker = BMKPointAnnotation()
//            marker.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//            mapView.addAnnotation(marker)
//            result(nil)
//        }
//    }
//
//    /// 移除地图标点
//    func removeMarker(_ call: FlutterMethodCall, mapView: BaiduMapView, result: @escaping FlutterResult) {
//        guard let args = call.arguments as? [String: Any],
//              let latitude = args["latitude"] as? Double,
//              let longitude = args["longitude"] as? Double else {
//            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid marker coordinates", details: nil))
//            return
//        }
//
//        DispatchQueue.main.async {
//            let annotationsToRemove = mapView.annotations.filter { annotation in
//                if let pointAnnotation = annotation as? BMKPointAnnotation {
//                    return pointAnnotation.coordinate.latitude == latitude &&
//                           pointAnnotation.coordinate.longitude == longitude
//                }
//                return false
//            }
//            mapView.removeAnnotations(annotationsToRemove)
//            result(nil)
//        }
//    }
}
