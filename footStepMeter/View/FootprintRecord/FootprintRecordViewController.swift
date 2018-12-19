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

    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIBarButtonItem(title: R.string.common.back(), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backButton
        title = R.string.footprintRecordView.title()

        tableView?.delegate = self
        tableView?.dataSource = self
        tableView.register(R.nib.customTableViewCell)

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

extension FootprintRecordViewController {
    
    /// モーダルを非表示にする処理
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate
extension FootprintRecordViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択時にハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension FootprintRecordViewController: UITableViewDataSource {

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
