//
//  PickerView+Rx.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/10/12.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: PickerView {

    public var delegate: DelegateProxy<PickerView, PickerViewDelegate> {
        return RxPickerViewDelegateProxy.proxy(for: base)
    }

    public var selectedItem: Observable<(Int, String)> {
        return RxPickerViewDelegateProxy.proxy(for: base).selectedItemSubject.asObservable()
    }

    public var closePickerView: Observable<Void> {
        return RxPickerViewDelegateProxy.proxy(for: base).closePickerViewSubject.asObservable()
    }
}
