//
//  Location.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/05/28.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import CoreLocation

/**
 位置情報オブジェクト
 */
class Location: NSObject, CLLocationManagerDelegate {
    
    private var lm: CLLocationManager?
    private var updatingLocationState: Bool = false
    weak var delegate: LocationDelegate?
    
    /**
     初期化処理
     */
    override init() {
        super.init()
        self.lm = CLLocationManager.init()
        self.lm?.allowsBackgroundLocationUpdates = true
        self.lm?.delegate = self
    }
    
    /**
     位置情報の利用許可の要求処理
     */
    func requestAuthorization() {
        if (self.lm?.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)))! {
            self.lm?.requestAlwaysAuthorization()
        }
    }
    
    /**
     位置情報の取得状態の要求処理
     
     - returns: 位置情報の取得状態 (true: 取得している / false: 取得していない)
     */
    func requestUpdatingLocationState() -> Bool {
        return updatingLocationState 
    }
    
    /**
     位置情報の取得精度を設定する処理
     
     - parameter accuracy: 取得したい精度
     */
    func setLocationAccuracy(accuracy: LocationAccuracy) {
        switch accuracy {
        case .bestForNavigation:
            self.lm?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        case .best:
            self.lm?.desiredAccuracy = kCLLocationAccuracyBest
        case .nearestTenMeters:
            self.lm?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        case .hundredMeters:
            self.lm?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        case .kilometer:
            self.lm?.desiredAccuracy = kCLLocationAccuracyKilometer
        case .threeKilometers:
            self.lm?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        }
    }
    
    /**
     位置情報の取得開始
     */
    func startUpdatingLocation() {
        // 位置情報の取得許可状態を確認
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways {
            // 位置情報の取得が許可されている場合は位置情報の取得を開始する
            self.lm?.startUpdatingLocation()
            self.updatingLocationState = true
        }
    }
    
    /**
     位置情報の取得停止処理
     */
    func stopUpdateLocation() {
        self.lm?.stopUpdatingLocation()
        self.updatingLocationState = false
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            requestAuthorization()
        case .authorizedAlways:
            print("位置情報の取得が許可されました。")
        case .denied:
            print("位置情報の取得が拒否されました。")
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last
        let lat = currentLocation?.coordinate.latitude
        let lng = currentLocation?.coordinate.longitude
        let accuracy = currentLocation?.horizontalAccuracy
        let speed = currentLocation?.speed
        let direction = currentLocation?.course
        
        delegate?.updateLocations(latitude: lat, longitude: lng, accuracy: accuracy, speed: speed, direction: direction)
    }
}

protocol LocationDelegate: class {
    func updateLocations(latitude: Double?, longitude: Double?, accuracy: Double?, speed: Double?, direction: Double?)
}
