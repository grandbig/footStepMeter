//
//  UIViewController+Color.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/10/06.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import UIKit

extension UIViewController {

    /// ステータスバーに背景色を設定
    ///
    /// - Parameter color: 背景色
    internal func setStatusBarBackgroundColor(color: UIColor) {
        if #available(iOS 13.0, *) {
            // 何もしない
        } else {
            guard let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIView else { return }
            guard let statusBar = statusBarWindow.subviews.first else { return }
            statusBar.backgroundColor = color
        }
    }
}
