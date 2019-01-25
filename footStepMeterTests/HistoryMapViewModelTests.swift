//
//  HistoryMapViewModelTests.swift
//  footStepMeterTests
//
//  Created by Takahiro Kato on 2019/01/19.
//  Copyright © 2019 Takahiro Kato. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import CoreLocation
import RealmSwift

@testable import footStepMeter

class HistoryMapViewModelTests: XCTestCase {

    var viewModel: HistoryMapViewModel!
    let scheduler = TestScheduler(initialClock: 0)
    static let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "inMemory"))
    static let dataTitle = "test1"

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

        let dependency = HistoryMapViewModel.Dependency(title: HistoryMapViewModelTests.dataTitle,
                                                        realmManager: MockRealmManagerClient())
        viewModel = HistoryMapViewModel(with: dependency)
    }

    override func tearDown() {
        super.tearDown()

        // inMemoryのデータは全て削除
        try! HistoryMapViewModelTests.realm.write {
            HistoryMapViewModelTests.realm.deleteAll()
        }
    }

    /// 初期ロード時に指定したデータが正しい内容でデータバインディングできることの確認
    func testViewDidLoadStream() {
        typealias ViewDidLoadResult = ([Footprint], [HistoryMapSectionModel])
        let disposeBag = DisposeBag()
        let results = scheduler.createObserver(ViewDidLoadResult.self)

        viewModel.viewDidLoadStream
            .bind(to: results)
            .disposed(by: disposeBag)

        scheduler.start()

        let items = [(R.string.historyMapView.cellTextHuman(), R.image.footprint()),
                     (R.string.historyMapView.cellTextAnimal(), R.image.animalFootprint())]
        let sectionModel = [HistoryMapSectionModel(items: items)]
        let mock = ViewDidLoadResult([createFootprint()], sectionModel)
        let expectedItems = [Recorded.next(0, mock)]
        let element = results.events.first!.value.element!

        // Footprintデータの確認
        XCTAssertEqual(element.0.first!.id, expectedItems.first!.value.element!.0.first!.id)
        XCTAssertEqual(element.0.first!.title, expectedItems.first!.value.element!.0.first!.title)
        XCTAssertEqual(element.0.first!.latitude, expectedItems.first!.value.element!.0.first!.latitude)
        XCTAssertEqual(element.0.first!.longitude, expectedItems.first!.value.element!.0.first!.longitude)
        XCTAssertEqual(element.0.first!.accuracy, expectedItems.first!.value.element!.0.first!.accuracy)
        XCTAssertEqual(element.0.first!.speed, expectedItems.first!.value.element!.0.first!.speed)
        XCTAssertEqual(element.0.first!.direction, expectedItems.first!.value.element!.0.first!.direction)

        // HistoryMapSectionModelデータの確認
        XCTAssertEqual(element.1.first!.items.first!.0, expectedItems.first!.value.element!.1.first!.items.first!.0)
        XCTAssertEqual(element.1.first!.items.first!.1, expectedItems.first!.value.element!.1.first!.items.first!.1)
        XCTAssertEqual(element.1.first!.items[1].0, expectedItems.first!.value.element!.1.first!.items[1].0)
        XCTAssertEqual(element.1.first!.items[1].1, expectedItems.first!.value.element!.1.first!.items[1].1)
    }

    /// メール送信時のデータバインディングの確認
    func testRequestSendMail() {
        let disposeBag = DisposeBag()
        let footprints = scheduler.createObserver([Footprint].self)

        viewModel.completeSendMailStream
            .bind(to: footprints)
            .disposed(by: disposeBag)

        scheduler.scheduleAt(10) { [unowned self] in
            self.viewModel.requestSendMailStream.accept(())
        }

        scheduler.start()

        let mock = [createFootprint()]
        let expectedItems = [Recorded.next(0, []), Recorded.next(10, mock)]

        XCTAssertEqual(footprints.events.first!.value.element!, expectedItems.first!.value.element!)
        XCTAssertEqual(footprints.events[1].value.element!.first!.id, expectedItems[1].value.element!.first!.id)
        XCTAssertEqual(footprints.events[1].value.element!.first!.title, expectedItems[1].value.element!.first!.title)
        XCTAssertEqual(footprints.events[1].value.element!.first!.latitude, expectedItems[1].value.element!.first!.latitude)
        XCTAssertEqual(footprints.events[1].value.element!.first!.longitude, expectedItems[1].value.element!.first!.longitude)
        XCTAssertEqual(footprints.events[1].value.element!.first!.accuracy, expectedItems[1].value.element!.first!.accuracy)
        XCTAssertEqual(footprints.events[1].value.element!.first!.speed, expectedItems[1].value.element!.first!.speed)
        XCTAssertEqual(footprints.events[1].value.element!.first!.direction, expectedItems[1].value.element!.first!.direction)
    }

    /// マップにプロットするアイコンの選択モーダルを表示/非表示に切り替える時のデータバインディングの確認
    func testRequestShowSelectIcon() {
        let disposeBag = DisposeBag()
        let isSelected = scheduler.createObserver(Bool.self)

        viewModel.completeShowSelectIconStream
            .bind(to: isSelected)
            .disposed(by: disposeBag)

        scheduler.start()

        scheduler.scheduleAt(10) {
            self.viewModel.requestShowSelectIconStream.accept(())
        }

        let expectedItems = [Recorded.next(0, false), Recorded.next(10, true)]

        for (key, event) in isSelected.events.enumerated() {
            XCTAssertEqual(event.value.element.unsafelyUnwrapped, expectedItems[key].value.element.unsafelyUnwrapped)
        }
    }

    /// マップにプロットするアイコンを変更する時のデータバインディングの確認
    func testRequestChangeFootprintIcon() {
        typealias RequestChangeFootprintIconResult = ([Footprint], FootprintIconMode)
        let disposeBag = DisposeBag()
        let results = scheduler.createObserver(RequestChangeFootprintIconResult.self)

        viewModel.completeChangeFootprintIconStream
            .bind(to: results)
            .disposed(by: disposeBag)

        scheduler.scheduleAt(10) {
            self.viewModel.requestChangeFootprintIconStream.accept(())
        }

        scheduler.start()

        let expectedItems = [Recorded.next(0, RequestChangeFootprintIconResult([], .human)),
                             Recorded.next(10, RequestChangeFootprintIconResult([createFootprint()], .animal))]

        XCTAssertEqual(results.events.first!.value.element!.0, expectedItems.first!.value.element!.0)
        XCTAssertEqual(results.events.first!.value.element!.1, expectedItems.first!.value.element!.1)
        XCTAssertEqual(results.events[1].value.element!.0.first!.id, expectedItems[1].value.element!.0.first!.id)
        XCTAssertEqual(results.events[1].value.element!.0.first!.title, expectedItems[1].value.element!.0.first!.title)
        XCTAssertEqual(results.events[1].value.element!.0.first!.latitude, expectedItems[1].value.element!.0.first!.latitude)
        XCTAssertEqual(results.events[1].value.element!.0.first!.longitude, expectedItems[1].value.element!.0.first!.longitude)
        XCTAssertEqual(results.events[1].value.element!.0.first!.accuracy, expectedItems[1].value.element!.0.first!.accuracy)
        XCTAssertEqual(results.events[1].value.element!.0.first!.speed, expectedItems[1].value.element!.0.first!.speed)
        XCTAssertEqual(results.events[1].value.element!.0.first!.direction, expectedItems[1].value.element!.0.first!.direction)
        XCTAssertEqual(results.events[1].value.element!.1, expectedItems[1].value.element!.1)
    }
}
