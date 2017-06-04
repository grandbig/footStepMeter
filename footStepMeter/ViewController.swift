//
//  ViewController.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/05/21.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITabBarDelegate, MKMapViewDelegate, PickerViewDelegate, LocationDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var countLabel: UILabel!
    private var location: Location? = nil
    private var footprintManager: FootprintManager? = nil
    private var pickerView: PickerView? = nil
    private var count: Int = 0
    private static let MAX_COUNT = 3600
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tabBar.delegate = self
        self.tabBar.items?[1].isEnabled = false
        
        // 位置情報関連の初期化処理
        self.location = Location.init()
        self.location?.delegate = self
        self.location?.requestAuthorization()
        
        // RealmSwift関連の初期化処理
        self.footprintManager = FootprintManager.init()
        
        // Picker関連の初期化処理
        pickerView = PickerView.init(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 260))
        self.view.addSubview(pickerView!)
        self.pickerView?.delegate = self
        
        // マップ関連の初期化処理
        self.mapView.delegate = self
        self.mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
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
            self.tabBar.items?[0].isEnabled = false
            self.tabBar.items?[1].isEnabled = true
        case 1:
            if (self.location?.requestUpdatingLocationState() ?? false) {
                self.showConfirm(title: "Confirm", message: "Stop to measure your location.", okCompletion: {
                    self.location?.stopUpdateLocation()
                    self.tabBar.selectedItem = nil
                    self.tabBar.items?[0].isEnabled = true
                    self.tabBar.items?[1].isEnabled = false
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
                let footprints = self.footprintManager?.selectByTitle((self.footprintManager?.title)!)
                for i in 0..<ViewController.MAX_COUNT {
                    if let footprint = footprints?[i] {
                        self.putAnnotation(footprint: footprint)
                        print("latitude: \(String(describing: footprint.latitude)), longitude: \(String(describing: footprint.longitude)), speed: \(String(describing: footprint.speed)), direction: \(String(describing: footprint.direction))")
                    }
                }

            }
        case 3:
            performSegue(withIdentifier: "settingsSegue", sender: nil)
        default:
            break
        }
    }
    
    // MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        } else {
            let identifier = "Pin"
            var annotationView: MKAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView.init(annotation: annotation, reuseIdentifier: identifier)
            }
            annotationView?.image = UIImage.init(named: "Footprint")
            annotationView?.annotation = annotation
            annotationView?.canShowCallout = true
            return annotationView
        }
    }
    
    // MARK: PickerViewDelegate
    func selectedAccuracy(selectedIndex: Int) {
        self.showTextConfirm(title: "Confirm", message: "Input the title", okCompletion: { (title: String) in
            // 保存する足跡のタイトルを設定
            self.footprintManager?.title = title
            // 計測する位置情報の精度を設定
            self.location?.setLocationAccuracy(accuracy: LocationAccuracy(rawValue: selectedIndex) ?? LocationAccuracy.init())
            // 位置情報の計測を開始
            self.location?.startUpdatingLocation()
        }) {
            self.tabBar.items?[0].isEnabled = true
            self.tabBar.selectedItem = nil
        }
    }
    
    func closePickerView() {
        self.tabBar.selectedItem = nil
        self.tabBar.items?[0].isEnabled = true
        self.tabBar.items?[1].isEnabled = false
    }
    
    // MARK: LocationDelegate
    func updateLocations(latitude: Double?, longitude: Double?, speed: Double?, direction: Double?) {
        self.count += 1
        self.countLabel.text = String(self.count)
        self.footprintManager?.createFootprint(latitude: latitude ?? 0, longitude: longitude ?? 0, speed: speed ?? 0, direction: direction ?? 0)
    }
    
    // MARK: Button Action
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        self.tabBar.selectedItem = nil
    }
    
    @IBAction func moveUserLocation(_ sender: Any) {
        self.mapView.setCenter(self.mapView.userLocation.coordinate, animated: true)
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
     TextField付き確認モーダルの表示処理
     
     - parameter title: アラートのタイトル
     - parameter message: アラートのメッセージ
     - parameter okCompletion: OKタップ時のCallback
     - parameter cancelCompletion: Cancelタップ時のCallback
     */
    private func showTextConfirm(title: String, message: String, okCompletion: @escaping ((String) -> Void), cancelCompletion: @escaping (() -> Void)) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            if let enteredText = alert.textFields?[0].text {
                okCompletion(enteredText)
                return
            }
            self.showAlert(title: "Alert", message: "Please input the text.", completion: {
                cancelCompletion()
            })
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel) { (action: UIAlertAction) in
            cancelCompletion()
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        // テキストフィールドの追加
        alert.addTextField { (textField: UITextField) in
        }
        
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
    
    /*
     アノテーションをマッピングする処理
     
     - parameter footprint: 足跡情報
     */
    private func putAnnotation(footprint: Footprint) {
        let latitude = footprint.latitude
        let longitude = footprint.longitude
        // CustomAnnotationの初期化
        let ann = CustomAnnotation.init(coordinate: CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude), title: "(\(latitude), \(longitude))", subtitle: "")
        // CustomAnnotationをマップに配置
        self.mapView.addAnnotation(ann)
    }
}
