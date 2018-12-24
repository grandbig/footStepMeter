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

/// 足跡履歴一覧画面
class FootprintRecordViewController: UIViewController, Injectable {
    typealias Dependency = FootprintViewModel

    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Properties
    private let viewModel: FootprintViewModel
    private let disposeBag = DisposeBag()
    private var rowTitles = [String]()
    private var rowFootprintCounts = [Int]()

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

        tableView?.delegate = self
        tableView?.dataSource = self
        tableView.register(R.nib.customTableViewCell)

        driveFromViewModel()
        bindFromViewModel()
        tableViewBindToViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Private Methods
extension FootprintRecordViewController {

    /// ViewModelのDriverを監視
    private func driveFromViewModel() {

        viewModel.savedRecords
            .drive(onNext: { [weak self] records in
                guard let strongSelf = self, let strongRecords = records else { return }
                for record in strongRecords {
                    strongSelf.rowTitles.append(record.key)
                    strongSelf.rowFootprintCounts.append(record.value)
                }
                strongSelf.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    /// ViewModelのObservableを監視
    private func bindFromViewModel() {

        viewModel.completeDeleteRecordStream
            .subscribe(onNext: { [weak self] indexPath in
                guard let strongSelf = self, let indexPath = indexPath else { return }
                let alert = UIAlertController(title: R.string.common.confirmTitle(),
                                              message: R.string.footprintRecordView.completeDeleteRecordMessage(),
                                              preferredStyle: .alert)
                _ = strongSelf.promptFor(alert: alert, isExistCancel: false)
                    .subscribe({ _ in
                        alert.dismiss(animated: false, completion: nil)
                    })

                strongSelf.rowTitles.remove(at: indexPath.row)
                strongSelf.rowFootprintCounts.remove(at: indexPath.row)
                // テーブルからの削除
                strongSelf.tableView.deleteRows(at: [indexPath], with: .fade)
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
    }

    /// モーダルを非表示にする処理
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Static Methods
extension FootprintRecordViewController {
    
    static func make() -> FootprintRecordViewController {
        let dependency = FootprintViewModel.Dependency(realmManager: RealmManager())
        let footprintRecordViewModel = FootprintViewModel(with: dependency)
        let footprintRecordViewController = FootprintRecordViewController(with: footprintRecordViewModel)
        return footprintRecordViewController
    }
}

// MARK: - UITableViewDelegate
extension FootprintRecordViewController: UITableViewDelegate {

    /// UITableViewに対するアクションを検知して、ViewModelにイベント通知
    private func tableViewBindToViewModel() {
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let strongSelf = self else { return }
                let title = strongSelf.rowTitles[indexPath.row]
                Observable.just((title, indexPath))
                    .bind(to: strongSelf.viewModel.requestDeleteRecordStream)
                    .disposed(by: strongSelf.disposeBag)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let strongSelf = self else { return }
                // 選択時にハイライト解除
                strongSelf.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDataSource
extension FootprintRecordViewController: UITableViewDataSource {

    // TODO: RxSwiftっぽくUITableViewDataSourceを扱う
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.customCellIdentifier,
                                                 for: indexPath)!
        cell.textLabel?.text = rowTitles[indexPath.row]
        let footprintCount = rowFootprintCounts[indexPath.row]
        cell.detailTextLabel?.text = "\(R.string.footprintRecordView.count())\(R.string.common.colon())\(footprintCount)"
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}
