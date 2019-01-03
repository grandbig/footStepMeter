//
//  FootprintRecordViewController.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/12/15.
//  Copyright © 2018 Takahiro Kato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

/// 足跡履歴一覧画面
class FootprintRecordViewController: UIViewController, Injectable {
    typealias Dependency = FootprintRecordViewModel

    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Properties
    private let viewModel: FootprintRecordViewModel
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<FootprintRecordSectionModel>!

    // MARK: - Initial methods
    required init(with dependency: Dependency) {
        viewModel = dependency
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIBarButtonItem(title: R.string.common.back(), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backButton
        title = R.string.footprintRecordView.title()

        tableView.register(R.nib.customTableViewCell)
        dataSource = RxTableViewSectionedReloadDataSource<FootprintRecordSectionModel>(
            configureCell: { _, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.customCellIdentifier,
                                                         for: IndexPath(row: indexPath.row, section: 0))!
                cell.textLabel?.text = item.0
                let detailText = "\(R.string.footprintRecordView.count())\(R.string.common.colon())\(item.1)"
                cell.detailTextLabel?.text = detailText
                cell.accessoryType = .disclosureIndicator

                return cell
        }, canEditRowAtIndexPath: { _, _ in
            return true
        })

        bindFromViewModel()
        tableViewDelegateBindToViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Private Methods
extension FootprintRecordViewController {

    /// ViewModelのObservableを監視
    private func bindFromViewModel() {

        viewModel.savedRecordStream
            .asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        viewModel.completeDeleteRecordStream
            .subscribe(onNext: { [weak self] result in
                guard let strongSelf = self else { return }
                if !result { return }
                let alert = UIAlertController(title: R.string.common.confirmTitle(),
                                              message: R.string.footprintRecordView.completeDeleteRecordMessage(),
                                              preferredStyle: .alert)
                _ = strongSelf.promptFor(alert: alert, isExistCancel: false)
                    .subscribe({ _ in
                        alert.dismiss(animated: false, completion: nil)
                    })
            })
            .disposed(by: disposeBag)

        viewModel.errorStream
            .subscribe(onNext: { [weak self] message in
                guard let strongSelf = self else { return }
                if message.count == 0 { return }
                let alert = UIAlertController(title: R.string.common.confirmTitle(),
                                              message: message,
                                              preferredStyle: .alert)
                _ = strongSelf.promptFor(alert: alert, isExistCancel: false)
                    .subscribe({ _ in
                        alert.dismiss(animated: false, completion: nil)
                    })
            })
            .disposed(by: disposeBag)

        viewModel.completeNavigateToHistoryMapStream
            .subscribe(onNext: { [weak self] title in
                guard let strongSelf = self else { return }
                if title.count == 0 { return }
                strongSelf.navigateToHistoryMap(title: title)
            }).disposed(by: disposeBag)
    }

    /// マップに足跡履歴を表示する画面に遷移する処理
    private func navigateToHistoryMap(title: String) {
        let viewContoller = HistoryMapViewController.make(title: title)
        navigationController?.pushViewController(viewContoller, animated: true)
    }

    /// モーダルを非表示にする処理
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Static Methods
extension FootprintRecordViewController {
    
    static func make() -> FootprintRecordViewController {
        let dependency = FootprintRecordViewModel.Dependency(realmManager: RealmManager())
        let footprintRecordViewModel = FootprintRecordViewModel(with: dependency)
        let footprintRecordViewController = FootprintRecordViewController(with: footprintRecordViewModel)
        return footprintRecordViewController
    }
}

// MARK: - UITableViewDelegate
extension FootprintRecordViewController {

    /// UITableViewに対するアクションを検知して、ViewModelにイベント通知
    private func tableViewDelegateBindToViewModel() {
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let strongSelf = self else { return }
                Observable.just(indexPath)
                    .bind(to: strongSelf.viewModel.requestDeleteRecordStream)
                    .disposed(by: strongSelf.disposeBag)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let strongSelf = self else { return }

                Observable.just(indexPath)
                    .bind(to: strongSelf.viewModel.requestNavigateToHistoryMapStream)
                    .disposed(by: strongSelf.disposeBag)

                // 選択時にハイライト解除
                strongSelf.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
