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
    private var selectedIndexPathToDelete: IndexPath?

    // MARK: Drivers
    private (set) var savedRecords: Driver<[String: Int]?>

    // MARK: PublishRelays
    let requestDeleteRecordStream = PublishRelay<(String, IndexPath)>()

    // MARK: BehaviorRelays
    let completeDeleteRecordStream = BehaviorRelay<IndexPath?>(value: nil)
    let errorStream = BehaviorRelay<String>(value: String())

    // MARK: Initial method
    init(with dependency: Dependency) {
        let realmManager = dependency.realmManager

        savedRecords = Observable.deferred({() -> Observable<[String: Int]?> in
            return realmManager.distinctByTitle()
        })
            .asDriver(onErrorJustReturn: nil)

        observeRequestDeleteRecord(realmManager: realmManager)
    }
}

// MARK: - Data Binding Handling
extension FootprintViewModel {

    private func observeRequestDeleteRecord(realmManager: RealmManagerClient) {

        requestDeleteRecordStream
            .flatMapLatest { (title, indexPath) -> Observable<Error?> in
                self.selectedIndexPathToDelete = indexPath
                return realmManager.delete(title)
            }
            .subscribe(onNext: { [weak self] error in
                guard let strongSelf = self else { return }
                guard let _ = error as? AppError else {
                    Observable.just(strongSelf.selectedIndexPathToDelete)
                        .bind(to: strongSelf.completeDeleteRecordStream)
                        .disposed(by: strongSelf.disposeBag)
                    return
                }
                Observable.just(R.string.footprintRecordView.failedDeletedRecordsErrorMessage())
                    .bind(to: strongSelf.errorStream)
                    .disposed(by: strongSelf.disposeBag)
            })
            .disposed(by: disposeBag)
    }
}
