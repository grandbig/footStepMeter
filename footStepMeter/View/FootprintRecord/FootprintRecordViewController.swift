//
//  FootprintRecordViewController.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/12/15.
//  Copyright © 2018 Takahiro Kato. All rights reserved.
//

import UIKit

/// 足跡履歴一覧画面
class FootprintRecordViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIBarButtonItem(title: R.string.common.back(), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backButton
        title = R.string.footprintRecordView.title()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Static Methods
extension FootprintRecordViewController {
    
    static func make() -> FootprintRecordViewController {
        let footprintRecordViewController = FootprintRecordViewController()
        return footprintRecordViewController
    }
}

extension FootprintRecordViewController {
    
    /// モーダルを非表示にする処理
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
}
