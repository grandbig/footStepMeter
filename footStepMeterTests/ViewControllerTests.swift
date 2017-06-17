//
//  ViewControllerTests.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/06/17.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Quick
import Nimble
import RealmSwift
@testable import footStepMeter

class ViewControllerTests: QuickSpec {
    override func spec() {
        var subject: ViewController!
        
        beforeEach {
            // StoryboardからViewControllerを初期化
            subject = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
            
            expect(subject.view).notTo(beNil())
            expect(subject.statusBarView).notTo(beNil())
            expect(subject.navigationBar).notTo(beNil())
            expect(subject.mapView).notTo(beNil())
            expect(subject.tabBar).notTo(beNil())
            expect(subject.currentLocationButton).notTo(beNil())
            expect(subject.countLabel).notTo(beNil())
        }
        
        it("countLabel default is ****") {
            expect(subject.countLabel.text).to(equal("****"))
        }
        
        it("User's current location move when tapped currentLocationButton") {
            subject.currentLocationButton.sendActions(for: UIControlEvents.touchUpInside)
            print(subject.mapView.region.span.latitudeDelta)
            print(subject.mapView.region.span.longitudeDelta)
            expect(String(format: "%.2f", subject.mapView.region.span.latitudeDelta)).to(equal("0.06"))
            expect(String(format: "%.2f", subject.mapView.region.span.longitudeDelta)).to(equal("0.05"))
        }
    }
}
