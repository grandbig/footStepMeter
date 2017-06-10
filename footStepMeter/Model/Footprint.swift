//
//  Footprint.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/06/04.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import RealmSwift

/**
 足跡
 */
class Footprint: Object {
    dynamic var id: Int = 0
    dynamic var title: String = ""
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    dynamic var speed: Double = 0.0
    dynamic var direction: Double = 0.0
    dynamic var created: Double = Date().timeIntervalSince1970
    
    // プライマリーキーの設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // インデックスの設定
    override static func indexedProperties() -> [String] {
        return ["title"]
    }
}
