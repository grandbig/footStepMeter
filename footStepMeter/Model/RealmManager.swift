//
//  RealmManager.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/10/13.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RealmSwift

protocol RealmManagerClient {
    // MARK: - Protocol Properties
    var title: String { get set }

    // MARK: - Protocol Methods
    func setSaveTitle(_ title: String)
    func createFootprint(location: CLLocation)
    func fetchFootprints() -> Observable<Results<Footprint>?>
    func fetchFootprintsByTitle(_ text: String) -> Observable<Results<Footprint>?>
    func existsByTitle(_ text: String) -> Observable<Bool>
    func distinctByTitle() -> Observable<[String: Int]?>
    func countFootprints() -> Observable<Int>
    func countFootprintsByTitle(_ text: String) -> Observable<Int>
}

final class RealmManager: NSObject, RealmManagerClient {

    // MARK: - Properties
    var title = String()

    // MARK: - Initial Methods
    override init() {
        super.init()
    }

    /// タイトルの保存処理
    ///
    /// - Parameter title: 保存したいタイトル
    func setSaveTitle(_ title: String) {
        self.title = title
    }

    // MARK: - CRUD

    /// 位置情報のデータの保存処理
    ///
    /// - Parameter location: 保存する位置情報
    func createFootprint(location: CLLocation) {
        do {
            let realm = try Realm()
            let footprint = Footprint()
            let savedLastFootprint = fetchAllFootprints()?.last
            footprint.id = (savedLastFootprint != nil) ? ((savedLastFootprint?.id)! + 1) : 0
            footprint.title = self.title
            footprint.latitude = location.coordinate.latitude
            footprint.longitude = location.coordinate.longitude
            footprint.accuracy = location.horizontalAccuracy
            footprint.speed = location.speed
            footprint.direction = location.course
            
            // Realmへのオブジェクトの書き込み
            try realm.write {
                realm.create(Footprint.self, value: footprint, update: false)
            }
        } catch let error as NSError {
            print("Error: code - \(error.code), description - \(error.description)")
        }
    }

    /// 保存している全位置情報データを取得する処理
    ///
    /// - Returns: 保存している全位置情報データ
    func fetchFootprints() -> Observable<Results<Footprint>?> {
        let footprints = fetchAllFootprints()
        return Observable.just(footprints)
    }

    /// 指定したタイトルで保存されている位置情報データを取得する処理
    ///
    /// - Parameter text: タイトル
    /// - Returns: 指定したタイトルで保存されている位置情報データ
    func fetchFootprintsByTitle(_ text: String) -> Observable<Results<Footprint>?> {
        do {
            let realm = try Realm()
            let footprints = realm.objects(Footprint.self).filter("title == '\(text)'")
            if footprints.count > 0 {
                return Observable.just(footprints)
            }
            return Observable.just(nil)
        } catch _ as NSError {
            return Observable.just(nil)
        }
    }

    /// 指定したタイトルで保存されている位置情報データがあるか確認する処理
    ///
    /// - Parameter text: タイトル
    /// - Returns: 存在する場合はtrue, 存在しない場合はfalseを返却する
    func existsByTitle(_ text: String) -> Observable<Bool> {
        do {
            let realm = try Realm()
            let footprints = realm.objects(Footprint.self).filter("title == '\(text)'")
            if footprints.count > 0 {
                return Observable.just(true)
            }
            return Observable.just(false)
        } catch _ as NSError {
            return Observable.just(false)
        }
    }

    /// 保存した足跡をタイトル別に取得する処理
    ///
    /// - Returns: [タイトル：足跡数]の配列
    func distinctByTitle() -> Observable<[String: Int]?> {
        do {
            let realm = try Realm()
            if let titles = realm.objects(Footprint.self).value(forKey: "title") as? [String] {
                let distinctTitles = Set(titles)
                var distinctFootprints = [String: Int]()
                for title in distinctTitles {
                    let count = realm.objects(Footprint.self).filter("title == '\(title)'").count
                    distinctFootprints[title] = count
                }
                return Observable.just(distinctFootprints)
            }
            return Observable.just(nil)
        } catch _ as NSError {
            return Observable.just(nil)
        }
    }

    /// 保存したい全位置情報の数を取得する処理
    ///
    /// - Returns: 保存している位置情報の数
    func countFootprints() -> Observable<Int> {
        do {
            let realm = try Realm()
            return Observable.just(realm.objects(Footprint.self).count)
        } catch _ as NSError {
            return Observable.just(0)
        }
    }

    /// 指定したタイトルで保存されている位置情報の数
    ///
    /// - Parameter text: タイトル
    /// - Returns: 保存している位置情報の数
    func countFootprintsByTitle(_ text: String) -> Observable<Int> {
        do {
            let realm = try Realm()
            let footprints = realm.objects(Footprint.self).filter("title == '\(text)'")
            return Observable.just(footprints.count)
        } catch _ as NSError {
            return Observable.just(0)
        }
    }

    // MARK: - Private Methods

    /// 保存している全位置情報データを取得する処理
    ///
    /// - Returns: 位置情報データ
    private func fetchAllFootprints() -> Results<Footprint>? {
        do {
            let footprints = try Realm().objects(Footprint.self).sorted(byKeyPath: "id")
            return footprints
        } catch _ as NSError {
            return nil
        }
    }
}
