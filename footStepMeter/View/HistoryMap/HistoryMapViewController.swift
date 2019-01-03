//
//  HistoryMapViewController.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2019/01/02.
//  Copyright © 2019 Takahiro Kato. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import RxDataSources

/// 足跡履歴の確認画面
final class HistoryMapViewController: UIViewController, Injectable {
    typealias Dependency = HistoryMapViewModel

    // MARK: - IBOutlets
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var selectableView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var toggleFootprintButton: UIButton!
    @IBOutlet private weak var mailButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!

    // MARK: - Properties
    private let viewModel: HistoryMapViewModel
    private let disposeBag = DisposeBag()

    // MARK: - Initial methods
    required init(with dependency: Dependency) {
        viewModel = dependency
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIBarButtonItem(title: R.string.common.back(), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backButton

        bindFromViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Static Methods
extension HistoryMapViewController {

    static func make(title: String) -> HistoryMapViewController {
        let dependency = HistoryMapViewModel.Dependency.init(title: title, realmManager: RealmManager())
        let viewModel = HistoryMapViewModel(with: dependency)
        let historyMapViewController = HistoryMapViewController(with: viewModel)
        return historyMapViewController
    }
}

// MARK: - Private Methods
extension HistoryMapViewController {

    /// モーダルを非表示にする処理
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }

    /// ViewModelのObservableを監視
    private func bindFromViewModel() {
        viewModel.viewDidLoadStream
            .asObservable()
            .subscribe(onNext: { [weak self] footprints in
                guard let strongSelf = self else { return }
                if footprints.count == 0 { return }
                strongSelf.title = footprints.first?.title
                strongSelf.mapView.putFootprints(footprints)
            })
            .disposed(by: disposeBag)
    }
}
