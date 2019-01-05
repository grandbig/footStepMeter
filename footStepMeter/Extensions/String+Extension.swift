//
//  String+Extension.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2019/01/05.
//  Copyright © 2019 Takahiro Kato. All rights reserved.
//

import Foundation

extension String {

    /// CSV形式に変換する処理
    ///
    /// - Parameter datas: 変換前の文字列
    /// - Returns: CSV形式に変換した文字列
    static func toCSV(datas: [[String]]) -> String {
        var result = String()
        for data in datas {
            result += data.joined(separator: ",") + "\n"
        }
        return result
    }
}
