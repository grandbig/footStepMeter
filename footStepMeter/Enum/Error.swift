//
//  Error.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/10/14.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

enum AppError: Error {
    case cancel
    case apiError(description: String)
    case decodeError
    case otherError(description: String)
}
