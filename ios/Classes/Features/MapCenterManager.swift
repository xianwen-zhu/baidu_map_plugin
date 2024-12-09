//
//  MapCenterManager.swift
//  baidu_map_plugin
//
//  Created by 朱先文 on 2024/12/6.
//
import Flutter

class MapCenterManager {
    static let shared = MapCenterManager()

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
}
