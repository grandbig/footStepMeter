//
//  Injectable.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/10/04.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import UIKit

protocol Injectable {
    associatedtype Dependency
    init(with dependency: Dependency)
}

extension Injectable where Dependency == Void {
    init() {
        self.init(with: ())
    }
}
