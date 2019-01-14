//
//  FootprintRecordViewModelTests.swift
//  footStepMeterTests
//
//  Created by Takahiro Kato on 2019/01/14.
//  Copyright © 2019 Takahiro Kato. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import CoreLocation
import RealmSwift

@testable import footStepMeter

class FootprintRecordViewModelTests: XCTestCase {

    var viewModel: FootprintRecordViewModel!
    let scheduler = TestScheduler(initialClock: 0)

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
    
    static let mockFootprints = { () -> Results<Footprint>? in
        let config = Realm.Configuration(inMemoryIdentifier: "inMemory")
        let realm = try! Realm(configuration: config)
        return realm.objects(Footprint.self).sorted(byKeyPath: "id")
    }
    
    static let mockDistinctData = { () -> [(String, Int)] in
        return [("test1", 1), ("test2", 3)]
    }

    private func setUpInitialFootprint() {
        let config = Realm.Configuration(inMemoryIdentifier: "inMemory")
        let realm = try! Realm(configuration: config)
        let footprint = Footprint()
        footprint.id = 1
        footprint.title = String()
        footprint.latitude = 35.0
        footprint.longitude = 137.0
        footprint.accuracy = 65.0
        footprint.speed = 1.0
        footprint.direction = 0.0
        try! realm.write {
            realm.create(Footprint.self, value: footprint, update: false)
        }
    }

    override func setUp() {
        super.setUp()
        let dependency = FootprintRecordViewModel.Dependency(realmManager: MockRealmManagerClient())
        viewModel = FootprintRecordViewModel(with: dependency)

        setUpInitialFootprint()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSavedRecordStream() {
        let disposeBag = DisposeBag()
        let footprintSectionModels = scheduler.createObserver([FootprintRecordSectionModel].self)

        viewModel.savedRecordStream
            .bind(to: footprintSectionModels)
            .disposed(by: disposeBag)

        scheduler.start()

        let items = [("test1", 1), ("test2", 3)]
        let mock = [FootprintRecordSectionModel(items: items)]
        let expectedItems = [next(0, mock)]
        let element = footprintSectionModels.events.first!.value.element

        XCTAssertEqual(element!.first!.items.first!.0, expectedItems.first!.value.element!.first!.items.first!.0)
        XCTAssertEqual(element!.first!.items.first!.1, expectedItems.first!.value.element!.first!.items.first!.1)
        XCTAssertEqual(element!.first!.items[1].0, expectedItems.first!.value.element!.first!.items[1].0)
        XCTAssertEqual(element!.first!.items[1].1, expectedItems.first!.value.element!.first!.items[1].1)
    }

}
