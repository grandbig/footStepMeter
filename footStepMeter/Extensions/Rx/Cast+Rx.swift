//
//  Cast+Rx.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/10/13.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import RxSwift
import RxCocoa

public func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    
    return returnValue
}

public func castOptionalOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T? {
    if NSNull().isEqual(object) {
        return nil
    }
    
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    
    return returnValue
}
