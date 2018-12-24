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

    // MARK: PublishRelays
    let requestDeleteRecordStream = PublishRelay<IndexPath>()

    // MARK: BehaviorRelays
    let savedRecordStream = BehaviorRelay<[(String, Int)]>(value: [])
    let completeDeleteRecordStream = BehaviorRelay<IndexPath?>(value: nil)
    let errorStream = BehaviorRelay<String>(value: String())

    // MARK: Initial method
    init(with dependency: Dependency) {
        let realmManager = dependency.realmManager

        Observable.deferred { () -> Observable<[(String, Int)]> in
            return realmManager.distinctByTitle()
        }
            .bind(to: savedRecordStream)
            .disposed(by: disposeBag)

        observeRequestDeleteRecord(realmManager: realmManager)
    }
}

// MARK: - Data Binding Handling
extension FootprintViewModel {

    private func observeRequestDeleteRecord(realmManager: RealmManagerClient) {

        requestDeleteRecordStream
            .flatMapLatest { indexPath -> Observable<Error?> in
                self.selectedIndexPathToDelete = indexPath
                let title = self.savedRecordStream.value[indexPath.row].0
                return realmManager.delete(title)
            }
            .subscribe(onNext: { [weak self] error in
                guard let strongSelf = self else { return }
                if error != nil {
                    Observable.just(R.string.footprintRecordView.failedDeletedRecordsErrorMessage())
                        .bind(to: strongSelf.errorStream)
                        .disposed(by: strongSelf.disposeBag)
                    return
                }
                guard let row = strongSelf.selectedIndexPathToDelete?.row else { return }
                var savedRecords = strongSelf.savedRecordStream.value
                savedRecords.remove(at: row)
                strongSelf.savedRecordStream.accept(savedRecords)
                Observable.just(strongSelf.selectedIndexPathToDelete)
                    .bind(to: strongSelf.completeDeleteRecordStream)
                    .disposed(by: strongSelf.disposeBag)
            })
            .disposed(by: disposeBag)
    }
}
