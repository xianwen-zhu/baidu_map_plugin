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

    init(frame: CGRect) {
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
        let redLayer = createRedCircleLayer(size: 50)
        container.layer.addSublayer(redLayer)
        redCircleLayer = redLayer
        centerIconContainer = container
    }

    /// 创建红色转圈的 CAShapeLayer
    private func createRedCircleLayer(size: CGFloat) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: size / 2, y: size / 2),
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
        animation.duration = 1.0
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
    }

    func mapView(_ mapView: BMKMapView, regionDidChangeAnimated animated: Bool) {
        print("地图移动结束")
        stopRedCircleAnimation() // 停止动画
    }
}

// MARK: - BMKLocationManagerDelegate
extension BaiduMapView: BMKLocationManagerDelegate {
    func bmkLocationManager(_ manager: BMKLocationManager, didUpdate location: BMKLocation?, orError error: Error?) {
        if let error = error {
            print("持续定位更新失败: \(error.localizedDescription)")
            return
        }

        guard let location = location, let coordinate = location.location?.coordinate else {
            print("持续定位更新失败，无有效数据")
            return
        }

        print("持续定位更新: 当前坐标 (\(coordinate.latitude), \(coordinate.longitude))")
        setCenter(latitude: coordinate.latitude, longitude: coordinate.longitude)
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
