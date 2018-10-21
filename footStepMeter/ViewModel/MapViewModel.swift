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
        let realmManager: RealmManagerClient
    }

    // MARK: - Properties
    private let disposeBag = DisposeBag()

    // MARK: Drivers
    private (set) var authorized: Driver<Bool>
    private (set) var location: Driver<CLLocationCoordinate2D>

    // MARK: PublishSubjects
    private let startUpdatingLocationStream = PublishSubject<(LocationAccuracy, String?)>()
    private let stopUpdatingLocationStream = PublishSubject<Void>()

    // MARK: BehaviorSubjects
    private let errorStream = BehaviorSubject<String?>(value: nil)
    private let doneUpdatingLocationModeDisabledStream = BehaviorSubject<()>(value: Void())
    private let cancelUpdatingLocationModeDisabledStream = BehaviorSubject<()>(value: Void())

    // MARK: Initial method
    init(with dependency: Dependency) {
        let locationManager = dependency.locationManager
        let realmManager = dependency.realmManager

        // Initialize stored properties
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
            .map {
                realmManager.createFootprint(location: $0)
                return $0.coordinate
        }

        // 位置情報の取得許可を要求
        locationManager.requestAlwaysAuthorization()
        // バックグラウンドでの位置情報取得を許可
        locationManager.allowsBackgroundLocationUpdates = true

        // Data Binding Handling
        observeStartUpdatingLocation(locationManager: locationManager, realmManager: realmManager)
        observeStopUpdatingLocation(locationManager: locationManager)
    }
}

// MARK: - Data Binding Handling
extension MapViewModel {

    /// startUpdatingLocationStreamにデータバインディングされてきた場合の処理
    ///
    /// - Parameters:
    ///   - locationManager: 位置情報管理マネージャ
    ///   - realmManager: Realm管理マネージャ
    func observeStartUpdatingLocation(locationManager: CLLocationManager, realmManager: RealmManagerClient) {

        startUpdatingLocationStream
            .subscribe { [weak self] event in
                guard let strongSelf = self, let element = event.element, let dataTitle = element.1 else { return }
                let locationAccuracy = LocationAccuracy.toCLLocationAccuracy(element.0)
                // タイトルの設定
                realmManager.setSaveTitle(dataTitle)
                // 同名タイトルの既存データが存在するか確認
                realmManager.existsByTitle(dataTitle)
                    .flatMapLatest({ isExist -> Observable<String?> in
                        if isExist {
                            return Observable.just(R.string.mapView.alreadySameTitleErrorMessage())
                        }
                        // 位置情報の取得精度を設定
                        locationManager.desiredAccuracy = locationAccuracy
                        // 位置情報の計測を開始
                        locationManager.startUpdatingLocation()
                        return Observable.just(nil)
                    })
                    .bind(to: strongSelf.errorStream)
                    .disposed(by: strongSelf.disposeBag)
            }.disposed(by: disposeBag)
    }

    /// stopUpdatingLocationStreamにデータバインディングされてきた場合の処理
    ///
    /// - Parameter locationManager: 位置情報管理マネージャ
    func observeStopUpdatingLocation(locationManager: CLLocationManager) {

        stopUpdatingLocationStream
            .subscribe { _ in
                // 位置情報の計測を停止
                locationManager.stopUpdatingLocation()
            }.disposed(by: disposeBag)
    }
}

// MARK: - Input
extension MapViewModel {

    var startUpdatingLocation: AnyObserver<(LocationAccuracy, String?)> {
        return startUpdatingLocationStream.asObserver()
    }
    var stopUpdatingLocation: AnyObserver<Void> {
        return stopUpdatingLocationStream.asObserver()
    }
}

// MARK: - Output
extension MapViewModel {

    var error: Observable<String?> {
        return errorStream.asObservable()
    }
}
