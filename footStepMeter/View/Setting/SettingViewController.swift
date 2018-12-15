//
//  SettingViewController.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/12/06.
//  Copyright © 2018 Takahiro Kato. All rights reserved.
//

import UIKit

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
    private var rowTitles = [String]()

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

        navigationController?.setNavigationBarColor(background: .mainBlue, text: .white, item: .white)
        let backButton = UIBarButtonItem(title: R.string.common.back(), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backButton
        title = R.string.settingView.title()

        tableView?.delegate = self
        tableView?.dataSource = self
        tableView.register(R.nib.customTableViewCell)
        rowTitles.append(R.string.settingView.footprintHistory())
        rowTitles.append(R.string.settingView.aboutApp())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Static Methods
extension SettingViewController {

    static func make() -> SettingViewController {
        let viewModel = SettingViewModel()
        let viewControler = SettingViewController(with: viewModel)
        return viewControler
    }
}

// MARK: - Private Methods
extension SettingViewController {

    @objc private func back() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択時にハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        let row = SettingTableViewRow(rawValue: indexPath.row) ?? SettingTableViewRow.footprintRecord
        switch row {
        case .footprintRecord:
            print("足跡履歴への遷移")
        case .aboutApp:
            print("このアプリについてへの遷移")
        }
    }
}

// MARK: - UITableViewDataSource
extension SettingViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.customCellIdentifier,
                                                                  for: indexPath)!
        cell.textLabel?.text = rowTitles[indexPath.row]
        return cell
    }
}
