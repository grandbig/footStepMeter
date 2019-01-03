//
//  SettingSectionModel.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2019/01/02.
//  Copyright © 2019 Takahiro Kato. All rights reserved.
//

import RxDataSources

struct SettingSectionModel {
    var items: [Item]
}
extension SettingSectionModel: SectionModelType {
    typealias Item = String
    
    init(original: SettingSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}
