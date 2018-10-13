//
//  MapViewModel.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/10/04.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

final class MapViewModel: Injectable {

    struct Dependency {
        let locationManager: CLLocationManager
    }
    private let disposeBag = DisposeBag()

    // MARK: Drivers
    private (set) var authorized: Driver<Bool>
    private (set) var location: Driver<CLLocationCoordinate2D>

    // MARK: PublishSubjects
    private let startUpdatingLocationStream = PublishSubject<(AlertActionType, String?)>()

    // MARK: BehaviorSubjects
    private let errorStream = BehaviorSubject<String>(value: String())

    // MARK: initial method
    init(with dependency: Dependency) {
        let locationManager = dependency.locationManager

        // 位置情報の取得許可の確認
        authorized = Observable.deferred({() -> Observable<CLAuthorizationStatus> in
            let status = CLLocationManager.authorizationStatus()
            return locationManager
                .rx.didChangeAuthorizationStatus
                .startWith(status)
        })
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
            .map {
                switch $0 {
                case .authorizedAlways:
                    return true
                default:
                    return false
                }
        }

        // 位置情報の取得情報の確認
        location = locationManager.rx.didUpdateLocations
            .asDriver(onErrorJustReturn: [])
            .flatMap {
                return $0.last.map(Driver.just) ?? Driver.empty()
            }
            .map { $0.coordinate }

        // 位置情報の取得許可を要求
        locationManager.requestAlwaysAuthorization()

        // TODO: AlertActionTypeとStringから判定
//        startUpdatingLocationStream
    }
}

// MARK: Input
extension MapViewModel {
    var startUpdatingLocation: AnyObserver<(AlertActionType, String?)> {
        return startUpdatingLocationStream.asObserver()
    }
}

// MARK: Output
extension MapViewModel {
    var error: Observable<String> {
        return errorStream.asObservable()
    }
}
