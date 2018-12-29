//
//  FootprintRecordSectionModel.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/12/27.
//  Copyright © 2018 Takahiro Kato. All rights reserved.
//

import RxDataSources

struct FootprintRecordSectionModel {
    var items: [Item]
}
extension FootprintRecordSectionModel: SectionModelType {
    typealias Item = (String, Int)
    
    init(original: FootprintRecordSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}
