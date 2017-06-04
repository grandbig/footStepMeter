//
//  ViewController.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/05/21.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITabBarDelegate, PickerViewDelegate, LocationDelegate {

    @IBOutlet weak var tabBar: UITabBar!
    private var location: Location? = nil
    private var footprintManager: FootprintManager? = nil
    private var pickerView: PickerView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tabBar.delegate = self
        
        self.location = Location.init()
        self.location?.delegate = self
        self.location?.requestAuthorization()
        
        self.footprintManager = FootprintManager.init()
        
        pickerView = PickerView.init(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 260))
        self.view.addSubview(pickerView!)
        self.pickerView?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: UITabBarDelegate
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("item.tag: \(item.tag)")
        switch item.tag {
        case 0:
            pickerView?.showPickerView()
        case 1:
            if (self.location?.requestUpdatingLocationState() ?? false) {
                self.showConfirm(title: "Confirm", message: "Stop to measure your location.", okCompletion: {
                    self.location?.stopUpdateLocation()
                    self.tabBar.selectedItem = nil
                }, cancelCompletion: {
                    self.tabBar.selectedItem = self.tabBar.items?[0]
                })
            } else {
                self.tabBar.selectedItem = nil
            }
        case 2:
            if (self.location?.requestUpdatingLocationState() ?? false) {
                self.showAlert(title: "Alert", message: "Please stop to measure your location.", completion: {})
            } else if (self.tabBar.selectedItem == self.tabBar.items?[2]) {
                // 既に選択している場合
                self.tabBar.selectedItem = nil
            } else {
                // 新たに選択した場合
                let footprints = self.footprintManager?.selectAll()
                for i in 0..<3600 {
                    let footprint = footprints?[i]
                    print("latitude: \(String(describing: footprint?.latitude)), longitude: \(String(describing: footprint?.longitude)), speed: \(String(describing: footprint?.speed)), direction: \(String(describing: footprint?.direction))")
                }

            }
        case 3:
            performSegue(withIdentifier: "settingsSegue", sender: nil)
        default:
            break
        }
    }
    
    // MARK: PickerViewDelegate
    func selectedAccuracy(selectedIndex: Int) {
        self.location?.setLocationAccuracy(accuracy: LocationAccuracy(rawValue: selectedIndex) ?? LocationAccuracy.init())
        self.location?.startUpdatingLocation()
    }
    
    func closePickerView() {
        self.tabBar.selectedItem = nil
    }
    
    // MARK: LocationDelegate
    func updateLocations(latitude: Double?, longitude: Double?, speed: Double?, direction: Double?) {
        self.footprintManager?.createFootprint(latitude: latitude ?? 0, longitude: longitude ?? 0, speed: speed ?? 0, direction: direction ?? 0)
    }
    
    // MARK: Button Action
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        self.tabBar.selectedItem = nil
    }
    
    // MARK: Other
    /*
     確認モーダルの表示処理
     
     - parameter title: アラートのタイトル
     - parameter message: アラートのメッセージ
     - parameter okCompletion: OKタップ時のCallback
     - parameter cancelCompletion: Cancelタップ時のCallback
     */
    private func showConfirm(title: String, message: String, okCompletion: @escaping (() -> Void), cancelCompletion: @escaping (() -> Void)) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            okCompletion()
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel) { (action: UIAlertAction) in
            cancelCompletion()
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    /*
     警告モーダルの表示処理
     
     - parameter title: アラートのタイトル
     - parameter message: アラートのメッセージ
     - parameter completion: OKタップ時のCallback
     */
    private func showAlert(title: String, message: String, completion: @escaping (() -> Void)) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            completion()
        }
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}
