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
import RealmSwift

final class MapViewModel: Injectable {

    struct Dependency {
        let locationManager: CLLocationManager
        let realmManager: RealmManagerClient
    }

    struct MapViewErrorResponse {
        var message: String?
        var isActiveStartButton: Bool
    }

    typealias Response = MapViewErrorResponse

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var locationCount = 0
    private var dataTitle = String()
    private var isUpdatingLocation = false
    private var isShowFootprints = false

    // MARK: Drivers
    private (set) var authorized: Driver<Bool>

    // MARK: PublishRelays
    private let startUpdatingLocationStream = PublishRelay<(LocationAccuracy, String?)>()
    private let stopUpdatingLocationStream = PublishRelay<Void>()
    private let showOrHideSavedLocationsStream = PublishRelay<Void>()

    // MARK: BehaviorRelays
    private let savedLocationStream = BehaviorRelay<[Footprint]>(value: [])
    private let hideLocationStream = BehaviorRelay<Void>(value: ())
    private let errorStream = BehaviorRelay<Response>(value: Response(message: nil, isActiveStartButton: true))
    private let countLocationStream = BehaviorRelay<Int>(value: 0)

    // MARK: Initial method
    init(with dependency: Dependency) {
        let locationManager = dependency.locationManager
        let realmManager = dependency.realmManager

        // Initialize stored properties
        // 位置情報の取得許可の確認
        authorized = Observable.deferred {() -> Observable<CLAuthorizationStatus> in
            let status = CLLocationManager.authorizationStatus()
            return locationManager
                .rx.didChangeAuthorizationStatus
                .startWith(status)
            }
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
            .map {
                switch $0 {
                case .authorizedAlways:
                    return true
                default:
                    return false
                }
        }

        // 位置情報の取得許可を要求
        locationManager.requestAlwaysAuthorization()
        // バックグラウンドでの位置情報取得を許可
        locationManager.allowsBackgroundLocationUpdates = true
        // バックグラウンドで位置情報取得がわかるように設定
        locationManager.showsBackgroundLocationIndicator = true

        // Data Binding Handling
        observeStartUpdatingLocation(locationManager: locationManager, realmManager: realmManager)
        observeStopUpdatingLocation(locationManager: locationManager)
        observeSelectSavedLocations(realmManager: realmManager)
        observeCountLocations(locationManager: locationManager, realmManager: realmManager)
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
                strongSelf.dataTitle = dataTitle
                let locationAccuracy = LocationAccuracy.toCLLocationAccuracy(element.0)
                // タイトルの設定
                realmManager.setSaveTitle(dataTitle)
                // 同名タイトルの既存データが存在するか確認
                realmManager.existsByTitle(dataTitle)
                    .flatMapLatest({ isExist -> Observable<Response> in
                        if isExist {
                            // TODO: ここで初期化せざるを得なくなっているのが冗長
                            strongSelf.dataTitle = String()
                            return Observable.just(Response(message: R.string.mapView.alreadySameTitleErrorMessage(),
                                                            isActiveStartButton: true))
                        }
                        // 位置情報の取得精度を設定
                        locationManager.desiredAccuracy = locationAccuracy
                        // 位置情報の計測を開始
                        locationManager.startUpdatingLocation()
                        strongSelf.isUpdatingLocation = true
                        strongSelf.locationCount = 0
                        return Observable.just(Response(message: nil, isActiveStartButton: true))
                    })
                    .asDriver(onErrorJustReturn: Response(message: R.string.mapView.unExpectedErrorMessage(),
                                                          isActiveStartButton: true))
                    .drive(strongSelf.errorStream)
                    .disposed(by: strongSelf.disposeBag)
            }
            .disposed(by: disposeBag)
    }

    /// stopUpdatingLocationStreamにデータバインディングされてきた場合の処理
    ///
    /// - Parameter locationManager: 位置情報管理マネージャ
    func observeStopUpdatingLocation(locationManager: CLLocationManager) {

        stopUpdatingLocationStream
            .subscribe { [weak self] _ in
                guard let strongSelf = self else { return }
                // 位置情報の計測を停止
                locationManager.stopUpdatingLocation()
                strongSelf.isUpdatingLocation = false
            }
            .disposed(by: disposeBag)
    }

    /// showOrHideSavedLocationsStreamにデータバインディングされてきた場合の処理
    ///
    /// - Parameter realmManager: Realm管理マネージャ
    func observeSelectSavedLocations(realmManager: RealmManagerClient) {

        showOrHideSavedLocationsStream
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                if strongSelf.isUpdatingLocation {
                    // 位置情報の取得を停止していない場合
                    Observable.just(Response(message: R.string.mapView.needToStopUpdatingLocationErrorMessage(),
                                             isActiveStartButton: false))
                        .asDriver(onErrorJustReturn: Response(message: R.string.mapView.unExpectedErrorMessage(),
                                                              isActiveStartButton: false))
                        .drive(strongSelf.errorStream)
                        .disposed(by: strongSelf.disposeBag)
                    return
                }
                if strongSelf.dataTitle.count == 0 {
                    // アプリ起動後に位置情報の計測を開始していない場合
                    Observable.just(Response(message: R.string.mapView.locationNotExistErrorMessage(),
                                             isActiveStartButton: true))
                        .asDriver(onErrorJustReturn: Response(message: R.string.mapView.unExpectedErrorMessage(),
                                                              isActiveStartButton: true))
                        .drive(strongSelf.errorStream)
                        .disposed(by: strongSelf.disposeBag)
                    return
                }
                if strongSelf.isShowFootprints {
                    // 既に、足跡を表示している(タブバーでFOOT VIEW選択済みの)場合、FOOT VIEW選択解除を指示
                    strongSelf.isShowFootprints = false
                    Observable.just(())
                        .asDriver(onErrorJustReturn: ())
                        .drive(strongSelf.hideLocationStream)
                        .disposed(by: strongSelf.disposeBag)
                    return
                }
                // 位置情報の取得を停止している場合、Realmから保存した位置情報を取得
                realmManager.fetchFootprintsByTitle(strongSelf.dataTitle)
                    .flatMapLatest({ results -> Observable<[Footprint]> in
                        guard let results = results else { return Observable.just([]) }
                        var footprints = [Footprint]()
                        let count = results.count
                        for i in 0..<count {
                            footprints.append(results[i])
                        }
                        strongSelf.isShowFootprints = true
                        return Observable.just(footprints)
                    })
                    .asDriver(onErrorJustReturn: [])
                    .drive(strongSelf.savedLocationStream)
                    .disposed(by: strongSelf.disposeBag)
            })
            .disposed(by: disposeBag)
    }

    /// 位置情報の最新値を計測して、取得できた位置情報数をカウント
    ///
    /// - Parameter locationManager: 位置情報管理マネージャ
    func observeCountLocations(locationManager: CLLocationManager, realmManager: RealmManagerClient) {

        // 位置情報の取得数の確認
        locationManager.rx.didUpdateLocations
            .flatMap {
                return $0.last.map(Observable.just) ?? Observable.empty()
            }
            .map { [weak self] location -> Int in
                guard let strongSelf = self else { return 0 }
                realmManager.createFootprint(location: location)
                strongSelf.locationCount += 1
                return strongSelf.locationCount
            }
            .asDriver(onErrorJustReturn: locationCount)
            .drive(countLocationStream)
            .disposed(by: disposeBag)
    }
}

// MARK: - Input
extension MapViewModel {

    var startUpdatingLocation: PublishRelay<(LocationAccuracy, String?)> {
        return startUpdatingLocationStream
    }
    var stopUpdatingLocation: PublishRelay<Void> {
        return stopUpdatingLocationStream
    }
    var showOrHideSavedLocations: PublishRelay<Void> {
        return showOrHideSavedLocationsStream
    }
}

// MARK: - Output
extension MapViewModel {

    var savedLocations: Driver<[Footprint]> {
        return savedLocationStream.asDriver()
    }
    var hideLocations: Driver<Void> {
        return hideLocationStream.asDriver()
    }
    // エラーメッセージ
    var error: Driver<Response> {
        return errorStream.asDriver()
    }
    var countLocations: Driver<Int> {
        return countLocationStream.asDriver()
    }
}
