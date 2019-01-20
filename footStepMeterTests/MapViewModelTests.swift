//
//  MapViewModelTests.swift
//  footStepMeterTests
//
//  Created by Takahiro Kato on 2019/01/20.
//  Copyright © 2019 Takahiro Kato. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import CoreLocation
import RealmSwift

@testable import footStepMeter

class MapViewModelTests: XCTestCase {

    var viewModel: MapViewModel!
    let scheduler = TestScheduler(initialClock: 0)
    static let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "inMemory"))

    /// テスト用のモックRealmManagerClient
    final class MockRealmManagerClient: RealmManagerClient {
        var title: String = String()

        func setSaveTitle(_ title: String) {
        }

        func createFootprint(location: CLLocation) {
        }

        func fetchFootprints() -> Results<Footprint>? {
            return nil
        }

        func fetchFootprints() -> Observable<Results<Footprint>?> {
            return Observable.just(FootprintRecordViewModelTests.mockFootprints())
        }

        func fetchFootprintsByTitle(_ text: String) -> Observable<Results<Footprint>?> {
            return Observable.just(FootprintRecordViewModelTests.mockFootprints())
        }

        func existsByTitle(_ text: String) -> Observable<Bool> {
            return Observable.just(false)
        }

        func distinctByTitle() -> [(String, Int)] {
            return FootprintRecordViewModelTests.mockDistinctData()
        }

        func distinctByTitle() -> Observable<[(String, Int)]> {
            return Observable.just(FootprintRecordViewModelTests.mockDistinctData())
        }

        func countFootprints() -> Observable<Int> {
            return Observable.just(10)
        }

        func countFootprintsByTitle(_ text: String) -> Observable<Int> {
            return Observable.just(10)
        }

        func delete(_ text: String) -> Observable<Error?> {
            return Observable.just(nil)
        }
    }
    final class MockCLLocationManager: CLLocationManager {

        override class func authorizationStatus() -> CLAuthorizationStatus {
            return .authorizedAlways
        }
    }

    static let mockFootprints = { () -> Results<Footprint>? in
        return realm.objects(Footprint.self).sorted(byKeyPath: "id")
    }

    static let mockDistinctData = { () -> [(String, Int)] in
        return [(HistoryMapViewModelTests.dataTitle, 1), ("test2", 3)]
    }

    private func setUpInitialFootprint() {
        let footprint = createFootprint()
        try! FootprintRecordViewModelTests.realm.write {
            FootprintRecordViewModelTests.realm.create(Footprint.self, value: footprint, update: false)
        }
    }

    private func createFootprint() -> Footprint {
        let footprint = Footprint()
        footprint.id = 1
        footprint.title = HistoryMapViewModelTests.dataTitle
        footprint.latitude = 35.0
        footprint.longitude = 137.0
        footprint.accuracy = 65.0
        footprint.speed = 1.0
        footprint.direction = 0.0
        return footprint
    }

    override func setUp() {
        super.setUp()
        // 初めにinMemoryに保存するデータを構築
        setUpInitialFootprint()

        let dependency = MapViewModel.Dependency(locationManager: CLLocationManager(), realmManager: MockRealmManagerClient())
        viewModel = MapViewModel(with: dependency)
    }

    override func tearDown() {
        super.tearDown()

        // inMemoryのデータは全て削除
        try! MapViewModelTests.realm.write {
            MapViewModelTests.realm.deleteAll()
        }
    }

    /// 初期ロード時にauthorizedに想定した値が格納されることを確認
    func testAuthorized() {
        let disposeBag = DisposeBag()
        let results = scheduler.createObserver(Bool.self)

        viewModel.authorized
            .drive(results)
            .disposed(by: disposeBag)

        scheduler.start()

        let expectedItems = [Recorded.next(0, true)]

        XCTAssertEqual(results.events.first!.value.element!, expectedItems.first!.value.element!)
    }

    /// 位置情報の計測開始後、エラーが発生していないことを確認
    func testStartUpdatingLocation() {
        
    }

    /// 保存した位置情報の表示ができることを確認
    func testSelectSavedLocation() {
        // エラーの数だけテスト項目が必要そう...
    }

    /// 計測した位置情報数を数えることができることを確認
    func testCountLocation() {
        // TODO: どうやって書く？
    }
}
