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
import RealmSwift

class HistoryViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var countLabel: UILabel!
    
    private var footprintManager: FootprintManager? = nil
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
    
    // MARK: Other
    /**
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
