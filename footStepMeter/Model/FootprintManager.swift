//
//  FootprintManager.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/06/04.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import RealmSwift

class FootprintManager {
    
    /** 足跡のタイトル */
    var title: String?
    
    /** イニシャライザ */
    init() {
    }
    
    /**
     足跡をRealmに保存する処理
     
     - parameter latitude: 緯度
     - parameter longitude: 経度
     - parameter speed: 速度
     - parameter direction: 方角
     */
    func createFootprint(latitude: Double, longitude: Double, speed: Double, direction: Double) {
        let realm = try! Realm()
        let footprint = Footprint()
        footprint.id = countFootprint()
        footprint.title = self.title!
        footprint.latitude = latitude
        footprint.longitude = longitude
        footprint.speed = speed
        footprint.direction = direction
        
        // Realmへのオブジェクトの書き込み
        try! realm.write {
            realm.create(Footprint.self, value: footprint, update: false)
        }
    }
    
    /**
     保存した足跡数の取得処理
     
     - returns: 保存した足跡の数
     */
    func countFootprint() -> Int {
        let realm = try! Realm()
        return realm.objects(Footprint.self).count
    }
    
    /**
     指定したタイトルの足跡数の取得処理
     
     - parameter text: 足跡のタイトル
     - returns: 指定したタイトルの足跡数
     */
    func countFootprintByTitle(_ text: String) -> Int {
        let realm = try! Realm()
        let footprints = realm.objects(Footprint.self).filter("title == '\(text)'")
        return footprints.count
    }
    
    /**
     保存した足跡全てを取得する処理
     
     - returns: 全ての足跡
     */
    func selectAll() -> Results<Footprint> {
        let footprints = try! Realm().objects(Footprint.self)
        return footprints
    }
    
    /**
     指定したタイトルの足跡全てを取得する処理
     
     - parameter text: 足跡のタイトル
     - returns: 指定したタイトルに紐づく足跡
     */
    func selectByTitle(_ text: String) -> Results<Footprint>? {
        let realm = try! Realm()
        let footprints = realm.objects(Footprint.self).filter("title == '\(text)'")
        if footprints.count > 0 {
            return footprints
        }
        return nil
    }
    
    /**
     指定したタイトルの足跡が保存されているかどうかを取得する処理
     
     - parameter text: 足跡のタイトル
     - returns: true->既に保存したタイトルの足跡がある場合 / false->既に保存したタイトルの足跡がない場合
     */
    func existsByTitle(_ text: String) -> Bool {
        let realm = try! Realm()
        let footprints = realm.objects(Footprint.self).filter("title == '\(text)'")
        if footprints.count > 0 {
            return true
        }
        return false
    }
    
    /**
     保存した足跡をタイトル別に取得する処理
     
     - returns: [タイトル：足跡数]の配列
     */
    func distinctByTitle() -> [String: Int]? {
        let realm = try! Realm()
        let distinctTitles = Set(realm.objects(Footprint.self).value(forKey: "title") as! [String])
        var distinctFootprints = [String: Int]()
        for title in distinctTitles {
            let count = self.countFootprintByTitle(title)
            distinctFootprints[title] = count
        }
        
        return distinctFootprints
    }
    
    /**
     保存した全ての足跡を削除する処理
     */
    func deleteAll() {
        let realm = try! Realm()
        realm.deleteAll()
    }
}
