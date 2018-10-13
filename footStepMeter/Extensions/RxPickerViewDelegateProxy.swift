//
//  PickerViewDelegateProxy.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/10/12.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension PickerView: HasDelegate {
    public typealias Delegate = PickerViewDelegate
}

public class RxPickerViewDelegateProxy: DelegateProxy<PickerView, PickerViewDelegate>,
    DelegateProxyType,
    PickerViewDelegate {

    public init(pickerView: PickerView) {
        super.init(parentObject: pickerView, delegateProxy: RxPickerViewDelegateProxy.self)
    }

    public static func registerKnownImplementations() {
        self.register { RxPickerViewDelegateProxy(pickerView: $0) }
    }

    public func selectedItem(index: Int) {
    }

    public func closePickerView() {
    }
}
