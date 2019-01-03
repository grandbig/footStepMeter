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
final class HistoryMapViewController: UIViewController {

    /// MARK: - IBOutlets
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var selectableView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var toggleFootprintButton: UIButton!
    @IBOutlet private weak var mailButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
