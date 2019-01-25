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

enum FootprintIconMode: Int {
    case human = 0
    case animal
}

final class HistoryMapViewModel: Injectable {
    struct Dependency {
        let title: String
        let realmManager: RealmManagerClient
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var footprints = [Footprint]()
    private var iconMode: FootprintIconMode = .human

    // MARK: PublishRelays
    let requestSendMailStream = PublishRelay<Void>()
    let requestShowSelectIconStream = PublishRelay<Void>()
    let requestChangeFootprintIconStream = PublishRelay<Void>()

    // MARK: BehaviorRelays
    let viewDidLoadStream = BehaviorRelay<([Footprint], [HistoryMapSectionModel])>(value: ([], []))
    let completeSendMailStream = BehaviorRelay<[Footprint]>(value: [])
    let completeShowSelectIconStream = BehaviorRelay<Bool>(value: false)
    let completeChangeFootprintIconStream = BehaviorRelay<([Footprint], FootprintIconMode)>(value: ([], .human))

    // MARK: Initial method
    init(with dependency: Dependency) {
        let title = dependency.title
        let realmManager = dependency.realmManager

        Observable.deferred {() -> Observable<Results<Footprint>?> in
            return realmManager.fetchFootprintsByTitle(title)
            }
            .flatMapLatest({ [weak self] results -> Observable<([Footprint], [HistoryMapSectionModel])> in
                guard let strongSelf = self, let results = results else { return Observable.just(([], [])) }
                let count = results.count
                for i in 0..<count {
                    strongSelf.footprints.append(results[i])
                }
                let items = [(R.string.historyMapView.cellTextHuman(), R.image.footprint()),
                             (R.string.historyMapView.cellTextAnimal(), R.image.animalFootprint())]
                return Observable.just((strongSelf.footprints, [HistoryMapSectionModel(items: items)]))
            })
            .bind(to: viewDidLoadStream)
            .disposed(by: disposeBag)

        observeRequestSendMail()
        observeRequestShowSelectIcon()
        observeRequestChangeFootprintIcon()
    }
}

// MARK: - Private methods
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

    private func observeRequestShowSelectIcon() {

        requestShowSelectIconStream
            .flatMapLatest({ _ -> Observable<Bool> in
                return Observable.just(true)
            })
            .bind(to: completeShowSelectIconStream)
            .disposed(by: disposeBag)
    }

    private func observeRequestChangeFootprintIcon() {

        requestChangeFootprintIconStream
            .flatMapLatest { [weak self] _ -> Observable<([Footprint], FootprintIconMode)> in
                guard let strongSelf = self else { return Observable.just(([], .human)) }
                strongSelf.toggleFootprintIconMode()
                return Observable.just((strongSelf.footprints, strongSelf.iconMode))
            }
            .bind(to: completeChangeFootprintIconStream)
            .disposed(by: disposeBag)
    }

    private func toggleFootprintIconMode() {
        switch iconMode {
        case .human:
            iconMode = .animal
        case .animal:
            iconMode = .human
        }
    }
}
