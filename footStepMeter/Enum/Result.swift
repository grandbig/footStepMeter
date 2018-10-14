//
//  File.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/10/14.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

enum Result<T> {
    case success(T)
    case failure(error: Error)
}
