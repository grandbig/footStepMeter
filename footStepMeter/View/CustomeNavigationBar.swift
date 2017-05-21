//
//  CustomeNavigationBar.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/05/21.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit

class CustomNavigationBar: UINavigationBar {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        super.frame = CGRect(x: 0, y: 0, width: super.frame.size.width, height: 64)
    }
}
