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

    @IBOutlet weak var statusBarView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    private var location: Location?
    private var footprintManager: FootprintManager?
    private var pickerView: PickerView?
    private var count: Int = 0
    private static let MAXCOUNT = 3600
    private var viewAnnotation: Bool = false
    private let alertTitle = NSLocalizedString("alertTitle", comment: "")
    private let confirmTitle = NSLocalizedString("confirmTitle", comment: "")
    private let okButton = NSLocalizedString("okButton", comment: "")
    private let cancelButton = NSLocalizedString("cancelButton", comment: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tabBar.delegate = self
        self.activeStartButton()
        
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
        
        if item.tag == 0 {
            pickerView?.showPickerView()
            self.inactivateStartButton()
        } else if item.tag == 1 {
            if self.location?.requestUpdatingLocationState() ?? false {
                self.showConfirm(title: self.confirmTitle, message: NSLocalizedString("confirmMessageToStopLocation", comment: ""), okCompletion: {
                    self.location?.stopUpdateLocation()
                    self.tabBar.selectedItem = nil
                    self.activeStartButton()
                }, cancelCompletion: {
                    self.tabBar.selectedItem = self.tabBar.items?[0]
                })
            } else {
                self.tabBar.selectedItem = nil
            }
        } else if item.tag == 2 {
            if self.location?.requestUpdatingLocationState() ?? false {
                // 位置情報の取得を停止していない場合
                self.showAlert(title: self.alertTitle, message: NSLocalizedString("alertMessageToStopLocation", comment: ""), completion: {})
            } else if self.viewAnnotation {
                // 足跡を表示している場合
                // 選択解除
                self.tabBar.selectedItem = nil
                // 地図上に表示されているアノテーションを全削除
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.viewAnnotation = false
            } else {
                // 足跡を表示していない場合
                if let savedTitle = self.footprintManager?.title {
                    // 保存した足跡データを取得して、マップに表示
                    if let footprints = self.footprintManager?.selectByTitle(savedTitle) {
                        // 足跡データを取得できた場合
                        let count = footprints.count <= ViewController.MAXCOUNT ? footprints.count : ViewController.MAXCOUNT
                        for i in 0..<count {
                            let footprint = footprints[i]
                            self.putAnnotation(footprint: footprint)
                        }
                    }
                    self.viewAnnotation = true
                    return
                }
                
                // アラートを表示
                self.showAlert(title: self.alertTitle, message: NSLocalizedString("alertMessageToSaveFootprint", comment: ""), completion: {
                    self.tabBar.selectedItem = nil
                })
            }
        } else {
            performSegue(withIdentifier: "settingsSegue", sender: nil)
        }
    }
    
    // MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        } else {
            let identifier = "Pin"
            var image = UIImage.init(named: "Footprint")
            var annotationView: MKAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView.init(annotation: annotation, reuseIdentifier: identifier)
            }
            if let customAnnotation = annotation as? CustomAnnotation {
                let direction = CGFloat(customAnnotation.direction ?? 0)
                image = image?.rotate(angle: direction)
            }
            
            annotationView?.image = image
            annotationView?.annotation = annotation
            annotationView?.canShowCallout = true
            return annotationView
        }
    }
    
    // MARK: PickerViewDelegate
    func selectedAccuracy(selectedIndex: Int) {
        self.showTextConfirm(title: self.confirmTitle, message: NSLocalizedString("confirmMessageToInputTitle", comment: ""), okCompletion: { (title: String) in
            if (self.footprintManager?.existsByTitle(title))! {
                // 既に同名タイトルの足跡を保存している場合
                self.showAlert(title: self.alertTitle, message: NSLocalizedString("alertMessageNotToSaveTitle", comment: ""), completion: {})
                self.activeStartButton()
                return
            }
            
            // 保存する足跡のタイトルを設定
            self.footprintManager?.title = title
            // 計測する位置情報の精度を設定
            self.location?.setLocationAccuracy(accuracy: LocationAccuracy(rawValue: selectedIndex) ?? LocationAccuracy.init())
            // 位置情報の計測を開始
            self.location?.startUpdatingLocation()
        }) {
            self.activeStartButton()
            self.tabBar.selectedItem = nil
        }
    }
    
    func closePickerView() {
        self.tabBar.selectedItem = nil
        self.activeStartButton()
    }
    
    // MARK: LocationDelegate
    func updateLocations(latitude: Double?, longitude: Double?, accuracy: Double?, speed: Double?, direction: Double?) {
        self.count += 1
        self.countLabel.text = String(self.count)
        self.footprintManager?.createFootprint(latitude: latitude ?? 0, longitude: longitude ?? 0, accuracy: accuracy ?? 0, speed: speed ?? 0, direction: direction ?? 0)
    }
    
    // MARK: Button Action
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        self.tabBar.selectedItem = nil
    }
    
    @IBAction func moveUserLocation(_ sender: Any) {
        // ズームレベルの変更
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: mapView.centerCoordinate, span: span)
        self.mapView.region = region
        // 中心位置を移動
        self.mapView.setCenter(self.mapView.userLocation.coordinate, animated: true)
    }
    
    // MARK: Other
    /**
     確認モーダルの表示処理
     
     - parameter title: アラートのタイトル
     - parameter message: アラートのメッセージ
     - parameter okCompletion: OKタップ時のCallback
     - parameter cancelCompletion: Cancelタップ時のCallback
     */
    private func showConfirm(title: String, message: String, okCompletion: @escaping (() -> Void), cancelCompletion: @escaping (() -> Void)) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction.init(title: self.okButton, style: UIAlertAction.Style.default) { _ in
            okCompletion()
        }
        let cancelAction = UIAlertAction.init(title: self.cancelButton, style: UIAlertAction.Style.cancel) { _ in
            cancelCompletion()
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    /**
     TextField付き確認モーダルの表示処理
     
     - parameter title: アラートのタイトル
     - parameter message: アラートのメッセージ
     - parameter okCompletion: OKタップ時のCallback
     - parameter cancelCompletion: Cancelタップ時のCallback
     */
    private func showTextConfirm(title: String, message: String, okCompletion: @escaping ((String) -> Void), cancelCompletion: @escaping (() -> Void)) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction.init(title: self.okButton, style: UIAlertAction.Style.default) { _ in
            if let enteredText = alert.textFields?[0].text {
                okCompletion(enteredText)
                return
            }
            self.showAlert(title: self.alertTitle, message: NSLocalizedString("alertMessageToInputTitle", comment: ""), completion: {
                cancelCompletion()
            })
        }
        let cancelAction = UIAlertAction.init(title: self.cancelButton, style: UIAlertAction.Style.cancel) { _ in
            cancelCompletion()
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        // テキストフィールドの追加
        alert.addTextField { _ in
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    /**
     警告モーダルの表示処理
     
     - parameter title: アラートのタイトル
     - parameter message: アラートのメッセージ
     - parameter completion: OKタップ時のCallback
     */
    private func showAlert(title: String, message: String, completion: @escaping (() -> Void)) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction.init(title: self.okButton, style: UIAlertAction.Style.default) { _ in
            completion()
        }
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    /**
     アノテーションをマッピングする処理
     
     - parameter footprint: 足跡情報
     */
    private func putAnnotation(footprint: Footprint) {
        let latitude = footprint.latitude
        let roundLatitude = String(format: "%.6f", latitude)
        let longitude = footprint.longitude
        let roundLongitude = String(format: "%.6f", longitude)
        let direction = footprint.direction >= 0 ? footprint.direction : 0
        let accuracy = footprint.accuracy
        // CustomAnnotationの初期化
        let ann = CustomAnnotation.init(coordinate: CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude), direction: direction, title: "\(roundLatitude), \(roundLongitude)", subtitle: "accuracy: \(accuracy)")
        // CustomAnnotationをマップに配置
        self.mapView.addAnnotation(ann)
    }
    
    /**
     スタートボタンの有効化処理
     */
    private func activeStartButton() {
        self.tabBar.items?[0].isEnabled = true
        self.tabBar.items?[1].isEnabled = false
    }
    
    /**
     スタートボタンの無効化処理
     */
    private func inactivateStartButton() {
        self.tabBar.items?[0].isEnabled = false
        self.tabBar.items?[1].isEnabled = true
    }
}
