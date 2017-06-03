//
//  LocationAccuracy.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/05/28.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation

/*
 位置情報の取得精度
 */
enum LocationAccuracy: Int {
    case bestForNavigation = 0
    case best
    case nearestTenMeters
    case hundredMeters
    case kilometer
    case threeKilometers
    
    static let defaultAccuracy = LocationAccuracy.bestForNavigation
    init() {
        self = LocationAccuracy.bestForNavigation
    }
}
