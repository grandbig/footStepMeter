//
//  HistoryMapViewModel.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2019/01/03.
//  Copyright © 2019 Takahiro Kato. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

final class HistoryMapViewModel: Injectable {
    struct Dependency {
        let title: String
        let realmManager: RealmManagerClient
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var footprints = [Footprint]()

    // MARK: PublishRelays
    let requestSendMailStream = PublishRelay<Void>()

    // MARK: BehaviorRelays
    let viewDidLoadStream = BehaviorRelay<[Footprint]>(value: [])
    let completeSendMailStream = BehaviorRelay<[Footprint]>(value: [])

    // MARK: Initial method
    init(with dependency: Dependency) {
        let title = dependency.title
        let realmManager = dependency.realmManager

        Observable.deferred {() -> Observable<Results<Footprint>?> in
            return realmManager.fetchFootprintsByTitle(title)
            }
            .flatMapLatest({ [weak self] results -> Observable<[Footprint]> in
                guard let strongSelf = self, let results = results else { return Observable.just([]) }
                let count = results.count
                for i in 0..<count {
                    strongSelf.footprints.append(results[i])
                }
                return Observable.just(strongSelf.footprints)
            })
            .bind(to: viewDidLoadStream)
            .disposed(by: disposeBag)

        observeRequestSendMail()
    }
}

extension HistoryMapViewModel {

    private func observeRequestSendMail() {

        requestSendMailStream
            .flatMapLatest { [weak self] _ -> Observable<[Footprint]> in
                guard let strongSelf = self else { return Observable.just([]) }
                return Observable.just(strongSelf.footprints)
            }
            .bind(to: completeSendMailStream)
            .disposed(by: disposeBag)
    }
}
