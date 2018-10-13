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

//    public var selectedItem: ControlEvent<Int> {
//        let source = delegate.methodInvoked(#selector(PickerViewDelegate.selectedItem(index:)))
//            .map { a in
//                return try castOrThrow(Int.self, a[1])
//        }
//        return ControlEvent(events: source)
//    }

    public var selectedItem: Observable<Int> {
        return delegate.methodInvoked(#selector(PickerViewDelegate.selectedItem(index:)))
            .map { a in
                return try castOrThrow(Int.self, a[1])
        }
    }
    
    public var closePickerView: ControlEvent<Void> {
        let source = delegate.methodInvoked(#selector(PickerViewDelegate.closePickerView))
            .map { a in
                return try castOrThrow(Void.self, a[1])
        }
        return ControlEvent(events: source)
    }
}
