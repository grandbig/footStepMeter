//
//  SettingViewController.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/12/06.
//  Copyright © 2018 Takahiro Kato. All rights reserved.
//

import UIKit

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

        tableView?.delegate = self
        tableView?.dataSource = self
        rowTitles.append(R.string.settingView.footprintHistory())
        rowTitles.append(R.string.settingView.aboutApp())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Private Methods
extension SettingViewController {

    static func make() -> SettingViewController {
        let viewModel = SettingViewModel()
        let viewControler = SettingViewController(with: viewModel)
        return viewControler
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択時にハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: cell選択時に画面遷移
    }
}

// MARK: - UITableViewDataSource
extension SettingViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.text = rowTitles[indexPath.row]
        return cell
    }
}

//class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//
//    // MARK: UITableViewDelegate
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // 選択時にハイライト解除
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        switch indexPath.row {
//        case 0:
//            performSegue(withIdentifier: "footprintHistorySegue", sender: nil)
//        case 1:
//            performSegue(withIdentifier: "aboutAppSegue", sender: nil)
//        default:
//            break
//        }
//    }
//
//    // MARK: Button Action
//    @IBAction func unwindToSetting(segue: UIStoryboardSegue) {
//    }
//}
