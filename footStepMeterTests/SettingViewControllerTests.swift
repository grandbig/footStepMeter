//
//  SettingViewControllerTests.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/06/17.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Quick
import Nimble
import RealmSwift
@testable import footStepMeter

class SettingViewControllerTests: QuickSpec {
    override func spec() {
        var subject: SettingViewController!
        
        beforeEach {
            // StoryboardからViewControllerを初期化
            subject = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController
            
            expect(subject.view).notTo(beNil())
            expect(subject.tableView).notTo(beNil())
        }
    }
}
