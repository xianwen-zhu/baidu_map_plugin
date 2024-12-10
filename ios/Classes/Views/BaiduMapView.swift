//
//  BaiduMapView.swift
//  baidu_map_plugin
//
//  Created by 朱先文 on 2024/12/7.
//



import Flutter
import UIKit
import BaiduMapAPI_Map
import BMKLocationKit

class BaiduMapView: NSObject, FlutterPlatformView {
    private var mapView: BMKMapView
    private var locationManager: BMKLocationManager?
    private var isRequestingLocation = false // 防止重复请求定位
    private let centerIconTag = 9999 // 中心点图标的标识符
    private var centerIconContainer: UIView? // 用于放置中心图标和动态效果的容器
    private var redCircleLayer: CAShapeLayer? // 红色转圈的动画图层
    /// 用户位置数据
    private var userLocation = BMKUserLocation()
    
    
    /// 提供一个 zoomLevel 属性
    var zoomLevel: CGFloat {
        get {
            return CGFloat(mapView.zoomLevel)
        }
        set {
            DispatchQueue.main.async {
                self.mapView.zoomLevel = Float(newValue)
            }
        }
    }
    
    
    init(frame: CGRect, messenger: FlutterBinaryMessenger) {
        self.mapView = BMKMapView(frame: frame)
        super.init()
        
        // 配置地图和中心点图标
        setupMapView()
        
        // 初始化定位管理器并启动定位请求
        setupLocationManager()
        startLocationRequest()
    }
    
    func view() -> UIView {
        return mapView
    }
    
    
    func dispose() {
        mapView.removeFromSuperview()
        locationManager?.stopUpdatingLocation()
        locationManager = nil
    }
    
    /// 配置地图视图
    private func setupMapView() {
        mapView.zoomLevel = 12.0 // 默认缩放级别
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.userTrackingMode = BMKUserTrackingModeHeading
        mapView.delegate = self
        
        // 添加中心点图标
        DispatchQueue.main.async {
            self.addCenterMarker()
        }
    }
    
    /// 初始化定位管理器
    private func setupLocationManager() {
        guard let apiKey = UserDefaults.standard.string(forKey: "BaiduMapAPIKey") else {
            print("Error: API Key is not initialized")
            return
        }
        
        // 确保用户已同意隐私政策
        BMKLocationAuth.sharedInstance().setAgreePrivacy(true)
        BMKLocationAuth.sharedInstance().checkPermision(withKey: apiKey, authDelegate: self)
        
        locationManager = BMKLocationManager()
        locationManager?.coordinateType = BMKLocationCoordinateType.BMK09LL // 百度坐标系
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 10
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation() // 启动持续定位
    }
    
    /// 对外提供用户当前位置
        func getUserLocation() -> BMKUserLocation? {
            return userLocation
        }
    
    /// 启动定位请求
    private func startLocationRequest() {
        guard !isRequestingLocation else {
            print("定位请求已在进行中，跳过重复请求")
            return
        }
        
        isRequestingLocation = true
        locationManager?.requestLocation(withReGeocode: true, withNetworkState: true) { [weak self] location, state, error in
            defer { self?.isRequestingLocation = false } // 请求完成后重置状态
            
            if let error = error {
                print("定位失败: \(error.localizedDescription)")
                return
            }
            
            guard let location = location, let coordinate = location.location?.coordinate else {
                print("定位数据为空")
                return
            }
            
            print("当前位置: \(coordinate.latitude), \(coordinate.longitude)")
            self?.setCenter(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }
    
    /// 设置地图中心点
    public func setCenter(latitude: Double, longitude: Double) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.setCenter(coordinate, animated: true)
    }
    
    /// 动态添加中心点图标
    private func addCenterMarker() {
        guard let parentView = mapView.superview else {
            print("地图视图没有父视图，无法添加中心点图标")
            return
        }
        
        // 检查是否已存在中心点图标
        if parentView.viewWithTag(centerIconTag) != nil {
            return
        }
        
        let container = UIView()
        container.tag = centerIconTag
        container.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 40),
            container.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // 添加中心点图标
        let centerIcon = UIImageView(image: UIImage(named: "center_icon"))
        centerIcon.contentMode = .scaleAspectFit
        centerIcon.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(centerIcon)
        
        NSLayoutConstraint.activate([
            centerIcon.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            centerIcon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            centerIcon.widthAnchor.constraint(equalToConstant: 50),
            centerIcon.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 添加红色动态圆圈
        let redLayer = createRedCircleLayer(size: 20)
        container.layer.addSublayer(redLayer)
        redCircleLayer = redLayer
        centerIconContainer = container
    }
    
    /// 创建红色转圈的 CAShapeLayer
    private func createRedCircleLayer(size: CGFloat) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: size / 2  +  9, y: size / 2 - 7),
                                        radius: size / 2 - 5,
                                        startAngle: -CGFloat.pi / 2,
                                        endAngle: CGFloat.pi * 1.5,
                                        clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = UIColor.red.cgColor
        layer.lineWidth = 4
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeEnd = 0 // 初始化为零
        return layer
    }
    
    /// 开始红色进度动画
    private func startRedCircleAnimation() {
        guard let redLayer = redCircleLayer else { return }
        redLayer.strokeEnd = 0
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.6
        redLayer.add(animation, forKey: "redCircleAnimation")
    }
    
    /// 停止红色进度动画
    private func stopRedCircleAnimation() {
        redCircleLayer?.removeAllAnimations()
    }
}

// MARK: - BMKMapViewDelegate
extension BaiduMapView: BMKMapViewDelegate {
    func mapView(_ mapView: BMKMapView, regionWillChangeAnimated animated: Bool) {
        print("地图即将移动")
        startRedCircleAnimation() // 开始动画
        FlutterEventHandler.shared.onRegionWillChange(animated: animated)
    }
    
    func mapView(_ mapView: BMKMapView, regionDidChangeAnimated animated: Bool) {
        print("地图移动结束")
        //stopRedCircleAnimation() // 停止动画
        FlutterEventHandler.shared.onRegionDidChange(animated: animated)
    }
    
    func mapView(_ mapView: BMKMapView!, onDrawMapFrame status: BMKMapStatus!) {
        print("地图移动状态变化")
        let isFullyRendered = status != nil
        FlutterEventHandler.shared.onMapRendered(fullyRendered: isFullyRendered)
    }
    
    func mapViewDidFinishLoading(_ mapView: BMKMapView) {
        print("地图加载完成")
        // 通知 Flutter 地图加载完成
        FlutterEventHandler.shared.onMapLoaded()
    }
    
    func mapView(_ mapView: BMKMapView!, onClickedMapBlank coordinate: CLLocationCoordinate2D) {
        print("用户点击了地图空白处: \(coordinate.latitude), \(coordinate.longitude)")
        FlutterEventHandler.shared.onMapClickedBlank(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    func mapView(_ mapView: BMKMapView!, onClickedMapPoi mapPoi: BMKMapPoi!) {
        guard let mapPoi = mapPoi else { return }
        print("用户点击了地图 POI: \(mapPoi.text ?? ""), 坐标: \(mapPoi.pt.latitude), \(mapPoi.pt.longitude)")
        FlutterEventHandler.shared.onMapClickedPoi(
            name: mapPoi.text ?? "",
            latitude: mapPoi.pt.latitude,
            longitude: mapPoi.pt.longitude
        )
    }
}

// MARK: - BMKLocationManagerDelegate
extension BaiduMapView: BMKLocationManagerDelegate {
    func bmkLocationManager(_ manager: BMKLocationManager, didUpdate location: BMKLocation?, orError error: Error?) {
        if let error = error {
            print("持续定位更新失败: \(error.localizedDescription)")
            FlutterEventHandler.shared.onLocationError(error: error.localizedDescription)
            return
        }
        
        guard let location = location, let coordinate = location.location?.coordinate else {
            print("持续定位更新失败，无有效数据")
            FlutterEventHandler.shared.onLocationError(error: "定位数据为空")
            return
        }
        
        print("持续定位更新: 当前坐标 (\(coordinate.latitude), \(coordinate.longitude))")
        setCenter(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        // 更新用户位置信息
        userLocation.location = location.location
        mapView.updateLocationData(userLocation) // 更新到地图视图
    }
    
    /**
     @brief 该方法为BMKLocationManager提供设备朝向的回调方法
     @param manager 提供该定位结果的BMKLocationManager类的实例
     @param heading 设备的朝向结果
     */
    func bmkLocationManager(_ manager: BMKLocationManager, didUpdate heading: CLHeading?) {
        NSLog("用户方向更新")
        userLocation.heading = heading
        mapView.updateLocationData(userLocation)
    }
    
    /**
     @brief 当定位发生错误时，会调用代理的此方法
     @param manager 定位 BMKLocationManager 类
     @param error 返回的错误，参考 CLError
     */
    func bmkLocationManager(_ manager: BMKLocationManager, didFailWithError error: Error?) {
        NSLog("定位失败")
    }
    
    
    
}

// MARK: - BMKLocationAuthDelegate
extension BaiduMapView: BMKLocationAuthDelegate {
    func onCheckPermissionState(_ iError: BMKLocationAuthErrorCode) {
        if iError == BMKLocationAuthErrorCode.success {
            print("AK 验证成功")
        } else {
            print("AK 验证失败，错误码: \(iError.rawValue)")
        }
    }
}



// MARK: - 对外提供的用户位置方法
extension BaiduMapView {
    /// 获取用户位置的纬度和经度
    func getCurrentLocation() -> (latitude: Double, longitude: Double)? {
        guard let location = userLocation.location else {
            return nil
        }
        return (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
}
