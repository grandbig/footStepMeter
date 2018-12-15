//
//  AboutAppViewController.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/12/15.
//  Copyright © 2018 Takahiro Kato. All rights reserved.
//

import UIKit

/// このアプリについて画面
final class AboutAppViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIBarButtonItem(title: R.string.common.back(), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backButton
        title = R.string.aboutAppView.title()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Static Methods
extension AboutAppViewController {

    static func make() -> AboutAppViewController {
        let aboutAppViewController = AboutAppViewController()
        return aboutAppViewController
    }
}

extension AboutAppViewController {

    /// モーダルを非表示にする処理
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
}
