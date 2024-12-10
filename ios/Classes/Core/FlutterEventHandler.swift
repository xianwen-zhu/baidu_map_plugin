//
//  FlutterEventHandler.swift
//  baidu_map_plugin
//
//  Created by 朱先文 on 2024/12/10.
//

import Flutter
import UIKit
import BaiduMapAPI_Map
import BMKLocationKit

/// 管理地图事件回调
class FlutterEventHandler {
    static let shared = FlutterEventHandler() // 单例模式
    private init() {}

    /// 发送事件到 Flutter
    func sendEvent(eventName: String, arguments: [String: Any]?) {
        guard let channel = BaiduMapPlugin.channel else {
            print("Flutter channel 未初始化")
            return
        }
        channel.invokeMethod(eventName, arguments: arguments)
    }

    /// 地图加载完成
    func onMapLoaded() {
        sendEvent(eventName: "onMapLoaded", arguments: nil)
    }

    /// 地图渲染完成
    func onMapRendered(fullyRendered: Bool) {
        sendEvent(eventName: "onMapRendered", arguments: ["fullyRendered": fullyRendered])
    }

    /// 地图移动状态变化
    func onRegionWillChange(animated: Bool) {
        sendEvent(eventName: "onRegionWillChange", arguments: ["animated": animated])
    }

    func onRegionDidChange(animated: Bool) {
        sendEvent(eventName: "onRegionDidChange", arguments: ["animated": animated])
    }

    /// 用户点击地图空白
    func onMapClickedBlank(latitude: Double, longitude: Double) {
        sendEvent(eventName: "onMapClickedBlank", arguments: [
            "latitude": latitude,
            "longitude": longitude
        ])
    }

    /// 用户点击地图 POI
    func onMapClickedPoi(name: String, latitude: Double, longitude: Double) {
        sendEvent(eventName: "onMapClickedPoi", arguments: [
            "name": name,
            "latitude": latitude,
            "longitude": longitude
        ])
    }

    /// 用户位置更新
    func onUserLocationUpdated(latitude: Double, longitude: Double) {
        sendEvent(eventName: "onUserLocationUpdated", arguments: [
            "latitude": latitude,
            "longitude": longitude
        ])
    }

    /// 定位失败
    func onLocationError(error: String) {
        sendEvent(eventName: "onLocationError", arguments: ["error": error])
    }
}
