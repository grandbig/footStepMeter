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

    internal lazy var selectedItemSubject = PublishSubject<(Int, String)>()
    internal lazy var closePickerViewSubject = PublishSubject<Void>()

    public func selectedItem(index: Int, title: String) {
        selectedItemSubject.onNext((index, title))
    }

    public func closePickerView() {
        closePickerViewSubject.onNext(Void())
    }

    deinit {
        self.selectedItemSubject.on(.completed)
        self.closePickerViewSubject.on(.completed)
    }
}
