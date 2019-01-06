//
//  HistoryMapSectionModel.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2019/01/06.
//  Copyright © 2019 Takahiro Kato. All rights reserved.
//

import RxDataSources

struct HistoryMapSectionModel {
    var items: [Item]
}
extension HistoryMapSectionModel: SectionModelType {
    typealias Item = (String, UIImage?)
    
    init(original: HistoryMapSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}
