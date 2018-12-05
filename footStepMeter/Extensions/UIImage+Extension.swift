//
//  UIImage+Extension.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/06/11.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {

    /// 画像の回転処理
    ///
    /// - Parameter angle: 回転角度
    /// - Returns: 回転後の画像
    func rotate(angle: CGFloat) -> UIImage {
        // コンテキストを開く
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.size.width, height: self.size.height), false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        // コンテキストの中心位置を設定
        context.translateBy(x: self.size.width/2, y: self.size.height/2)
        // Y軸の補正
        context.scaleBy(x: 1.0, y: -1.0)

        // 回転角のラジアン変換
        let radian: CGFloat = (-angle) * CGFloat(Double.pi) / 180.0
        context.rotate(by: radian)
        // 画像の描画
        context.draw(self.cgImage!, in: CGRect.init(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        // コンテキストを閉じる
        let rotatedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return rotatedImage
    }

    /// 画像のりサイズ
    ///
    /// - Parameter size: 変更したいサイズ
    /// - Returns: リサイズ後の画像
    func resize(_ size: CGSize) -> UIImage? {
        let widthRatio = size.width / size.width
        let heightRatio = size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio

        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
}
