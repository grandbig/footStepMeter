//
//  CustomAnnotation.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/06/04.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import MapKit

/**
 カスタムアノテーション
 */
class CustomAnnotation:NSObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D
    public var title: String?
    public var subtitle: String?
    
    /**
     イニシャライザ
     
     - parameter coordinate: 位置情報
     - parameter title: タイトル
     - parameter subtitle: サブタイトル
     */
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        
        super.init()
    }
}
