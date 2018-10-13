//
//  AppDelegate.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/05/21.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let dependency = MapViewModel.Dependency.init(locationManager: CLLocationManager())
        let viewController = MapViewController(with: MapViewModel(with: dependency))

        // ナビゲーションコントローラの色を設定
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.barTintColor = UIColor.mainBlue  // 背景色
        navigationController.navigationBar.isTranslucent = false    // ナビゲーションバーのぼかしを排除
        navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]  // タイトルの文字色
        navigationController.navigationBar.tintColor = .white   // アイテムの文字色
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}
