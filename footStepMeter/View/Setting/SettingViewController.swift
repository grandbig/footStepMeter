//
//  SettingViewController.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/12/06.
//  Copyright © 2018 Takahiro Kato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

/// 設定画面のテーブルビューの行
///
/// - footprintRecord: 足跡履歴
/// - aboutApp: このアプリについて
enum SettingTableViewRow: Int {
    case footprintRecord = 0
    case aboutApp
}

/// 設定画面
final class SettingViewController: UIViewController, Injectable {
    typealias Dependency = SettingViewModel

    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Properties
    private let viewModel: SettingViewModel
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SettingSectionModel>!

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

        navigationController?.setNavigationBarColor(background: .mainColor, text: .white, item: .white)
        let backButton = UIBarButtonItem(title: R.string.common.back(), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backButton
        title = R.string.settingView.title()

        tableView.register(R.nib.customTableViewCell)
        dataSource = RxTableViewSectionedReloadDataSource<SettingSectionModel>(
            configureCell: { _, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.customCellIdentifier,
                                                         for: IndexPath(row: indexPath.row, section: 0))!
                cell.textLabel?.text = item
                cell.accessoryType = .disclosureIndicator

                return cell
        })

        bindFromViewModel()
        tableViewDelegateBindToViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Static Methods
extension SettingViewController {

    static func make() -> SettingViewController {
        let viewModel = SettingViewModel(with: SettingViewModel.Dependency.init())
        let viewControler = SettingViewController(with: viewModel)
        return viewControler
    }
}

// MARK: - Private Methods
extension SettingViewController {

    /// モーダルを非表示にする処理
    @objc private func back() {
        dismiss(animated: true, completion: nil)
    }

    /// このアプリについて画面に遷移する処理
    private func navigateToAboutApp() {
        let viewContoller = AboutAppViewController.make()
        navigationController?.pushViewController(viewContoller, animated: true)
    }

    /// 足跡履歴に遷移する処理
    private func navigateToFootprintRecord() {
        let viewContoller = FootprintRecordViewController.make()
        navigationController?.pushViewController(viewContoller, animated: true)
    }

    /// ViewModelのObservableを監視
    private func bindFromViewModel() {
        viewModel.viewDidLoadStream
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController {

    private func tableViewDelegateBindToViewModel() {
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let strongSelf = self else { return }
                // 選択時にハイライト解除
                strongSelf.tableView.deselectRow(at: indexPath, animated: true)

                let row = SettingTableViewRow(rawValue: indexPath.row) ?? SettingTableViewRow.footprintRecord
                switch row {
                case .footprintRecord:
                    strongSelf.navigateToFootprintRecord()
                case .aboutApp:
                    strongSelf.navigateToAboutApp()
                }
            })
            .disposed(by: disposeBag)
    }
}
