//
//  MapKit+Extension.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2019/01/04.
//  Copyright © 2019 Takahiro Kato. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {

    /// マップに足跡をプロットする処理
    ///
    /// - Parameter footprints: 足跡データ
    func putFootprints(_ footprints: [Footprint]) {
        footprints.forEach { footprint in
            let latitude = footprint.latitude
            let longitude = footprint.longitude
            let roundLatitude = String(format: "%.6f", latitude)
            let roundLongitude = String(format: "%.6f", longitude)
            let direction = footprint.direction >= 0 ? footprint.direction : 0
            let accuracy = footprint.accuracy
            // CustomAnnotationの初期化
            let ann = CustomAnnotation.init(coordinate: CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude),
                                            direction: direction,
                                            title: "\(roundLatitude), \(roundLongitude)", subtitle: "accuracy: \(accuracy)")
            // CustomAnnotationをマップにプロット
            self.addAnnotation(ann)
        }
    }
}
