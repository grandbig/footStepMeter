//
//  UINavigationController+Color.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/12/15.
//  Copyright © 2018 Takahiro Kato. All rights reserved.
//

import UIKit

extension UINavigationController {

    /// ナビゲーションバーの各種色を設定する処理
    ///
    /// - Parameters:
    ///   - background: 背景色
    ///   - text: 文字色
    ///   - item: ボタンなどのアイテムの色
    internal func setNavigationBarColor(background: UIColor, text: UIColor, item: UIColor) {
        // ナビゲーションコントローラの色を設定
        self.navigationBar.barTintColor = background    // 背景色
        self.navigationBar.isTranslucent = false        // ナビゲーションバーのぼかしを排除
        self.navigationBar.titleTextAttributes = [.foregroundColor: text]  // タイトルの文字色
        self.navigationBar.tintColor = item             // アイテムの文字色
    }
}
