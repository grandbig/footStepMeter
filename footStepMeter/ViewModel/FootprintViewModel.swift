//
//  FootprintViewModel.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/12/16.
//  Copyright © 2018 Takahiro Kato. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

final class FootprintViewModel: Injectable {

    struct Dependency {
        let realmManager: RealmManagerClient
    }

    // MARK: - Properties
    private let disposeBag = DisposeBag()

    // MARK: Drivers
    private (set) var savedRecords: Driver<[String: Int]?>

    // MARK: Initial method
    init(with dependency: Dependency) {
        let realmManager = dependency.realmManager

        savedRecords = Observable.deferred({() -> Observable<[String: Int]?> in
            return realmManager.distinctByTitle()
        })
            .asDriver(onErrorJustReturn: nil)
    }
}
