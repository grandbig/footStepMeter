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

final class FootprintRecordViewModel: Injectable {

    struct Dependency {
        let realmManager: RealmManagerClient
    }

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var sectionModels = [FootprintRecordSectionModel]()
    private var selectedIndexPathToDelete: IndexPath?

    // MARK: PublishRelays
    let requestDeleteRecordStream = PublishRelay<IndexPath>()

    // MARK: BehaviorRelays
    let savedRecordStream = BehaviorRelay<[FootprintRecordSectionModel]>(value: [])
    let completeDeleteRecordStream = BehaviorRelay<Bool>(value: false)
    let errorStream = BehaviorRelay<String>(value: String())

    // MARK: Initial method
    init(with dependency: Dependency) {
        let realmManager = dependency.realmManager

        Observable.deferred {() -> Observable<[FootprintRecordSectionModel]> in
            self.sectionModels = [FootprintRecordSectionModel(items: realmManager.distinctByTitle())]
            return Observable.just(self.sectionModels)
        }
            .bind(to: savedRecordStream)
            .disposed(by: disposeBag)

        observeRequestDeleteRecord(realmManager: realmManager)
    }
}

// MARK: - Data Binding Handling
extension FootprintRecordViewModel {

    private func observeRequestDeleteRecord(realmManager: RealmManagerClient) {

        requestDeleteRecordStream
            .flatMapLatest { indexPath -> Observable<Error?> in
                self.selectedIndexPathToDelete = indexPath
                // Sectionは1つしかないため先頭のみ取得する
                let title = self.sectionModels.first?.items[indexPath.row].0 ?? String()
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
                guard let row = strongSelf.selectedIndexPathToDelete?.row,
                    var sectionModel = strongSelf.sectionModels.first else { return }
                sectionModel.items.remove(at: row)
                strongSelf.sectionModels = [FootprintRecordSectionModel(items: sectionModel.items)]

                // tableViewに最新のrowデータを流して更新する
                strongSelf.savedRecordStream.accept(strongSelf.sectionModels)
                Observable.just(true)
                    .bind(to: strongSelf.completeDeleteRecordStream)
                    .disposed(by: strongSelf.disposeBag)
            })
            .disposed(by: disposeBag)
    }
}
