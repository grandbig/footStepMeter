//
//  SettingViewControllerTests.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/06/17.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import footStepMeter

class SettingViewModelTests: XCTestCase {

    var viewModel: SettingViewModel!
    let scheduler = TestScheduler(initialClock: 0)

    override func setUp() {
        super.setUp()

        let dependency = SettingViewModel.Dependency()
        viewModel = SettingViewModel(with: dependency)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testViewDidLoadStream() {
        let disposeBag = DisposeBag()
        let settingSectionModels = scheduler.createObserver([SettingSectionModel].self)

        viewModel.viewDidLoadStream
            .bind(to: settingSectionModels)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let items = [R.string.settingView.footprintHistory(), R.string.settingView.aboutApp()]
        let mock = [SettingSectionModel(items: items)]
        let expectedItems = [next(0, mock)]
        let element = settingSectionModels.events.first!.value.element
        XCTAssertEqual(element!.first!.items, expectedItems.first!.value.element!.first!.items)
    }
}
