//
//  HistoryViewController.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/06/11.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import MessageUI
import RealmSwift

class HistoryViewController: UIViewController, MKMapViewDelegate, MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var selectableView: UIView!
    @IBOutlet weak var tableView: UITableView!
    private var rowTitle = [String]()
    private let rowImageName = ["Footprint", "AnimalFootprint"]
    private var annotationImageName = "Footprint"
    
    private var footprintManager: FootprintManager?
    private var footprints: Results<Footprint>?
    private static let MAXCOUNT = 3600
    var historyTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // RealmSwift関連の初期化処理
        self.footprintManager = FootprintManager.init()
        
        // マップ関連の初期化処理
        self.mapView.delegate = self
        
        // テーブルビューの初期化処理
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.rowTitle = [NSLocalizedString("selectableHumanIconRowTitle", comment: ""), NSLocalizedString("selectableAnimalIconRowTitle", comment: "")]
        
        if let footprints = self.footprintManager?.selectByTitle(self.historyTitle) {
            // 足跡データを取得できた場合
            self.footprints = footprints
            let firstFootprint: Footprint? = self.footprints?.first
            self.moveToMapCenterPosition(footprint: firstFootprint)
            self.putAnnotations(footprints: self.footprints!)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        } else {
            let identifier = "Pin"
            var image = UIImage.init(named: self.annotationImageName)
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
    
    // MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            break
        case .failed:
            break
        case .saved:
            break
        case .sent:
            break
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択時にハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        // アノテーション画像の変換
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.annotationImageName = rowImageName[indexPath.row]
        self.putAnnotations(footprints: self.footprints!)
        // UIViewを非表示
        self.selectableView.isHidden = true
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rowTitle.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "FootprintsCell", for: indexPath)
        cell.imageView?.image = UIImage.init(named: self.rowImageName[indexPath.row])?.resize(CGSize.init(width: 32, height: 32))
        cell.textLabel?.text = self.rowTitle[indexPath.row]
        
        return cell
    }
    
    // MARK: Button Action
    @IBAction func sendMail(_ sender: Any) {
        if self.footprints != nil {
            var datas: [[String]] = [["id", "latitude", "longitude", "accuracy", "speed", "direction", "created"]]
            let footprints = self.footprints
            for footprint in footprints! {
                let data: [String] = [String(footprint.id), String(footprint.latitude), String(footprint.longitude), String(footprint.accuracy), String(footprint.speed), String(footprint.direction), String(footprint.created)]
                datas.append(data)
            }
            
            self.sendMailWithCSV(subject: NSLocalizedString("sendMailSubject", comment: ""), message: "", csv: datas)
        }
    }
    
    @IBAction func showFootprintView(_ sender: Any) {
        self.selectableView.isHidden = false
    }
    
    @IBAction func cancelSelectFootprint(_ sender: Any) {
        self.selectableView.isHidden = true
    }
    
    // MARK: Other
    /**
     1つのアノテーションをマッピングする処理
     
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
     複数のアノテーションをマッピングする処理
     
     - parameter footprints: 全足跡情報
     */
    private func putAnnotations(footprints: Results<Footprint>) {
        let count = footprints.count <= HistoryViewController.MAXCOUNT ? footprints.count : HistoryViewController.MAXCOUNT
        self.countLabel.text = String(count)
        for i in 0..<count {
            let footprint = footprints[i]
            self.putAnnotation(footprint: footprint)
        }
    }
    
    /**
     マップの中心位置を移動
     
     - parameter footprint: 足跡情報
     */
    private func moveToMapCenterPosition(footprint: Footprint?) {
        if footprint != nil {
            // 足跡情報がある場合
            // ズームレベルの変更
            let coordinate = CLLocationCoordinate2DMake((footprint?.latitude ?? 0), (footprint?.longitude ?? 0))
            let delta = 0.001
            let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
            // 中心位置と尺度を設定
            let region = MKCoordinateRegion(center: coordinate, span: span)
            self.mapView.region = region
            // 中心位置を移動
            self.mapView.setCenter(coordinate, animated: true)
        }
    }
    
    /**
     CSV形式に変換する処理
     
     - parameter datas: 変換前データ
     - returns: CSV形式に変換したデータ
     */
    private func toCSV(datas: [[String]]) -> String {
        var result: String = ""
        for data in datas {
            result += data.joined(separator: ",") + "\n"
        }
        return result
    }
    
    /**
     CSVファイルを添付してメールを送信する処理
     
     - parameter subject: タイトル
     - parameter message: メール本文
     - parameter csv: CSVデータ
     */
    private func sendMailWithCSV(subject: String, message: String, csv: [[String]]) {
        
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        
        mailViewController.setSubject(subject)
        mailViewController.setMessageBody(message, isHTML: false)
        mailViewController.addAttachmentData(toCSV(datas: csv).data(using: String.Encoding.utf8, allowLossyConversion: false)!, mimeType: "text/csv", fileName: "sample.csv")
        self.present(mailViewController, animated: true) {}
    }
}
