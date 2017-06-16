//
//  footStepMeterTests.swift
//  footStepMeterTests
//
//  Created by Takahiro Kato on 2017/05/21.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import XCTest
import Quick
import Nimble
import RealmSwift
@testable import footStepMeter

class footStepMeterTests: QuickSpec {
    
    override func spec() {
        describe("Realm Database") {
            // テスト用のRealmデータ保存ファイルを作成
            // 保存場所はdefault.realmと同じでファイル名のみtest.realmに変更
            var config = Realm.Configuration()
            config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("test.realm")
            Realm.Configuration.defaultConfiguration = config
            // 上記の設定情報を利用してRealmを扱う
            let realm = try! Realm(configuration: config)
            let mock_title = "mock_title"
            let footprintManager = FootprintManager.init()
            footprintManager.title = mock_title
            
            beforeEach {
                // テスト用にモックデータを追加
                let footprint = Footprint()
                footprint.id = 0
                footprint.title = mock_title
                footprint.latitude = 35.678622
                footprint.longitude = 139.767573
                footprint.accuracy = 65
                footprint.speed = 1.0
                footprint.direction = 10.0
                footprint.created = 1497622723
                
                try! realm.write {
                    realm.create(Footprint.self, value: footprint, update: false)
                }
                
                expect(footprint).notTo(beNil())
            }
            
            // 取得内容の整合性およびカウント数のチェック
            it("can get footprints") {
                let footprints = footprintManager.selectAll()
                expect(footprints).notTo(beNil())
                expect(footprints.count).to(equal(1))
                expect(footprints[0].title).to(equal(mock_title))
                expect(footprints[0].latitude).to(equal(35.678622))
                expect(footprints[0].longitude).to(equal(139.767573))
                expect(footprints[0].accuracy).to(equal(65))
                expect(footprints[0].speed).to(equal(1.0))
                expect(footprints[0].direction).to(equal(10.0))
            }
            
            // 取得内容の整合性およびカウント数のチェック
            it("can create new footprint") {
                footprintManager.createFootprint(latitude: 35.678623, longitude: 139.767574, accuracy: 5.0, speed: 2.0, direction: 15.0)
                let footprints = footprintManager.selectAll()
                expect(footprints).notTo(beNil())
                expect(footprints.count).to(equal(2))
                expect(footprints[1].title).to(equal(mock_title))
                expect(footprints[1].latitude).to(equal(35.678623))
                expect(footprints[1].longitude).to(equal(139.767574))
                expect(footprints[1].accuracy).to(equal(5.0))
                expect(footprints[1].speed).to(equal(2.0))
                expect(footprints[1].direction).to(equal(15.0))
            }
            
            // カウント数のチェック
            it("can count footprints") {
                footprintManager.createFootprint(latitude: 35.678623, longitude: 139.767574, accuracy: 5.0, speed: 2.0, direction: 15.0)
                let count = footprintManager.countFootprint()
                expect(count).to(equal(2))
            }
            
            // カウント数のチェック
            it("can count footprints by specifying the title") {
                footprintManager.createFootprint(latitude: 35.678623, longitude: 139.767574, accuracy: 5.0, speed: 2.0, direction: 15.0)
                let count = footprintManager.countFootprintByTitle(mock_title)
                expect(count).to(equal(2))
            }
            
            // 存在チェック
            it("can find footprint by specifying the title") {
                expect(footprintManager.existsByTitle(mock_title)).to(beTrue())
            }
            
            // 存在チェック
            it("cannot find footprint specifying the by title") {
                expect(footprintManager.existsByTitle("mock_title2")).to(beFalse())
            }
            
            // 取得内容の整合性チェック
            it("get footprints by title") {
                footprintManager.title = "mock_title2"
                footprintManager.createFootprint(latitude: 35.678623, longitude: 139.767574, accuracy: 5.0, speed: 2.0, direction: 15.0)
                let footprints = footprintManager.distinctByTitle()
                expect(footprints?[mock_title]).to(equal(1))
                expect(footprints?["mock_title2"]).to(equal(1))
            }
            
            // カウント数のチェック
            it("can delete footprints") {
                footprintManager.delete(mock_title)
                let footprints = footprintManager.selectAll()
                expect(footprints.count).to(equal(0))
            }
            
            // カウント数のチェック
            it("can delete all footprints") {
                footprintManager.title = "mock_title2"
                footprintManager.createFootprint(latitude: 35.678623, longitude: 139.767574, accuracy: 5.0, speed: 2.0, direction: 15.0)
                footprintManager.deleteAll()
                let footprints = footprintManager.selectAll()
                expect(footprints.count).to(equal(0))
            }
            
            afterEach {
                // テスト終了後にデータを全て削除
                try! realm.write {
                    realm.deleteAll()
                }
            }
        }
    }
}
