//
//  SettingViewModel.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/12/06.
//  Copyright © 2018 Takahiro Kato. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class SettingViewModel: Injectable {
    typealias Dependency = Void

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var sectionModels = [SettingSectionModel]()

    // MARK: BehaviorRelays
    let viewDidLoadStream = BehaviorRelay<[SettingSectionModel]>(value: [])

    // MARK: Initial method
    init(with dependency: Dependency) {

        Observable.deferred {() -> Observable<[SettingSectionModel]> in
            let items = [R.string.settingView.footprintHistory(), R.string.settingView.aboutApp()]
            self.sectionModels = [SettingSectionModel(items: items)]
            return Observable.just(self.sectionModels)
            }
            .bind(to: viewDidLoadStream)
            .disposed(by: disposeBag)
    }
}
