//
//  UIColor+AppColor.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/10/13.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import UIKit

extension UIColor {
    class var mainColor: UIColor { return UIColor(named: "mainColor") ?? #colorLiteral(red: 0.01568627451, green: 0.2, blue: 1, alpha: 1) }
    class var mainTextColor: UIColor { return UIColor(named: "mainTextColor") ?? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) }
    class var mainBackgroundColor: UIColor { return UIColor(named: "mainBackgroundColor") ?? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
}
