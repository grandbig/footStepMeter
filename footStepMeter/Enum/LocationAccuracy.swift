//
//  LocationAccuracy.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/05/28.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import CoreLocation

/// 位置情報の取得精度
enum LocationAccuracy: String, CaseIterable {
    case bestForNavigation
    case best
    case nearestTenMeters
    case hundredMeters
    case kilometer
    case threeKilometers

    /// CLLocationAccuracyに変換する処理
    ///
    /// - Parameter accuracy: LocationAccuracyの値
    /// - Returns: 変換したCLLocationAccuracy
    func toCLLocationAccuracy(_ accuracy: LocationAccuracy) -> CLLocationAccuracy {
        switch accuracy {
        case .bestForNavigation:
            return kCLLocationAccuracyBestForNavigation
        case .best:
            return kCLLocationAccuracyBest
        case .nearestTenMeters:
            return kCLLocationAccuracyNearestTenMeters
        case .hundredMeters:
            return kCLLocationAccuracyHundredMeters
        case .kilometer:
            return kCLLocationAccuracyKilometer
        case .threeKilometers:
            return kCLLocationAccuracyThreeKilometers
        }
    }
}
