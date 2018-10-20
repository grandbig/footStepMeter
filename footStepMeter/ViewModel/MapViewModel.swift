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
    private let startUpdatingLocationStream = PublishSubject<(LocationAccuracy, AlertActionType, String?)>()

    // MARK: BehaviorSubjects
    private let errorStream = BehaviorSubject<String?>(value: nil)

    // MARK: initial method
    init(with dependency: Dependency) {
        let locationManager = dependency.locationManager
        let realmManager = dependency.realmManager

        // initialize stored properties
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

        // Data Binding Handling
        observeStartUpdatingLocation(locationManager: locationManager, realmManager: realmManager)
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
                guard let strongSelf = self else { return }
                guard let element = event.element else { return }
                let locationAccuracy = LocationAccuracy.toCLLocationAccuracy(element.0)
                let alertActionType = element.1
                let dataTitle = element.2
                switch alertActionType {
                case .ok:
                    guard let dataTitle = dataTitle else { return }
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
                case .cancel:
                    break
                }
            }.disposed(by: disposeBag)
    }
}

// MARK: - Input
extension MapViewModel {
    var startUpdatingLocation: AnyObserver<(LocationAccuracy, AlertActionType, String?)> {
        return startUpdatingLocationStream.asObserver()
    }
}

// MARK: - Output
extension MapViewModel {
    var error: Observable<String?> {
        return errorStream.asObservable()
    }
}
