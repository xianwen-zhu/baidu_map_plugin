//
//  MapSettingsManager.swift
//  baidu_map_plugin
//
//  Created by 朱先文 on 2024/12/9.
//

import Foundation
import BaiduMapAPI_Map

/// 管理地图设置的类
class MapSettingsManager {
    
    static let shared = MapSettingsManager()
    
    private init() {}
    
    /// 设置地图缩放等级
    func setZoomLevel(_ mapView: BMKMapView, zoomLevel: Float) {
        mapView.zoomLevel = zoomLevel
        print("地图缩放等级设置为: \(zoomLevel)")
    }
    
    
    /// 设置地图中心点图标
    /// - Parameters:
    ///   - mapView: 目标 BMKMapView 实例
    ///   - iconName: 图标的文件名（如 "center_icon"）
    /// 在地图视图的中心添加一个图标
    /// - Parameters:
    ///   - mapView: 地图视图
    ///   - iconName: 图标的文件名
    func addCenterMarkerToMap(_ mapView: BMKMapView, iconName: String) {
        // 检查父视图是否存在
        guard let parentView = mapView.superview else {
            print("地图视图没有父视图，无法添加中心图标")
            return
        }

        // 确保图标只添加一次
        if parentView.viewWithTag(9999) != nil {
            print("中心图标已存在")
            return
        }

        // 加载图标
        guard let image = UIImage(named: iconName) else {
            print("无法加载中心点图标资源: \(iconName)")
            return
        }

        // 创建 UIImageView 并添加到父视图
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: (mapView.frame.width - 32) / 2, y: (mapView.frame.height - 32) / 2, width: 32, height: 32)
        imageView.tag = 9999 // 设置一个标记，防止重复添加

        parentView.addSubview(imageView)
        print("中心点图标已添加到地图中心")
    }
    
    /// 设置地图类型
    func setMapType(_ mapView: BMKMapView, type: BMKMapType) {
        mapView.mapType = type
        print("地图类型设置为: \(type.rawValue)")
    }
    
    /// 重置地图到默认状态
    func resetMapView(_ mapView: BMKMapView) {
        mapView.zoomLevel = 15.0
        mapView.mapType = .standard
        print("地图已重置为默认状态")
    }
}
