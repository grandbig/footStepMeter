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

class HistoryViewController: UIViewController, MKMapViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var countLabel: UILabel!
    
    private var footprintManager: FootprintManager? = nil
    private var footprints: Results<Footprint>?
    private static let MAX_COUNT = 3600
    var historyTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // RealmSwift関連の初期化処理
        self.footprintManager = FootprintManager.init()
        
        // マップ関連の初期化処理
        self.mapView.delegate = self
        
        if let footprints = self.footprintManager?.selectByTitle(self.historyTitle) {
            // 足跡データを取得できた場合
            self.footprints = footprints
            let count = footprints.count <= HistoryViewController.MAX_COUNT ? footprints.count : HistoryViewController.MAX_COUNT
            self.countLabel.text = String(count)
            for i in 0..<count {
                let footprint = footprints[i]
                self.putAnnotation(footprint: footprint)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
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
    
    // MARK: Button Action
    @IBAction func sendMail(_ sender: Any) {
        if (self.footprints != nil) {
            var datas: [[String]] = [["id", "latitude", "longitude", "accuracy", "speed", "direction", "created"]]
            let footprints = self.footprints
            for footprint in footprints! {
                let data: [String] = [String(footprint.id), String(footprint.latitude), String(footprint.longitude), String(footprint.accuracy), String(footprint.speed), String(footprint.direction), String(footprint.created)]
                datas.append(data)
            }
            
            self.sendMailWithCSV(subject: "CSVデータの添付", message: "", csv: datas)
        }
    }
    
    // MARK: Other
    /**
     アノテーションをマッピングする処理
     
     - parameter footprint: 足跡情報
     */
    private func putAnnotation(footprint: Footprint) {
        let latitude = footprint.latitude
        let longitude = footprint.longitude
        let direction = footprint.direction >= 0 ? footprint.direction : 0
        // CustomAnnotationの初期化
        let ann = CustomAnnotation.init(coordinate: CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude), direction: direction, title: "(\(latitude), \(longitude))", subtitle: "")
        // CustomAnnotationをマップに配置
        self.mapView.addAnnotation(ann)
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
