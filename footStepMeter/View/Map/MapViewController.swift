//
//  MapViewController.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/10/04.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

/// マップ画面
final class MapViewController: UIViewController, Injectable {
    typealias Dependency = MapViewModel

    // MARK: - IBOutlets
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var tabBar: UITabBar!
    @IBOutlet private weak var searchButton: UIButton!

    // MARK: - Properties
    private let viewModel: MapViewModel
    private let disposeBag = DisposeBag()
    private let defaultCoordinateSpan = 0.05
    private var pickerView: PickerView?

    // MARK: - Initial methods
    required init(with dependency: Dependency) {
        viewModel = dependency
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.setUserTrackingMode(.follow, animated: true)
        setStatusBarBackgroundColor(color: UIColor.mainBlue)

        let selectItems = LocationAccuracy.allCases.map { $0.rawValue }
        pickerView = PickerView(selectItems: selectItems)
        if let pickerView = pickerView {
            self.view.addSubview(pickerView)
        }

        tabBar.selectedItem = nil

        bindToViewModel()
        driveFromViewModel()
        driveToViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Binding Methods
extension MapViewController {

    // MARK: - Bind to ViewModel
    private func bindToViewModel() {

        pickerView?.rx.selectedItem
            .asObservable()
            .subscribe({ [weak self] event in
                guard let strongSelf = self else { return }
                guard let title = event.element?.1 else { return }
                // PickerViewで選択した位置情報の取得精度
                let locationAccuracy = LocationAccuracy(rawValue: title) ?? LocationAccuracy.bestForNavigation
                // 今回計測する位置情報データのタイトルを入力するアラートを表示
                let alert = UIAlertController(title: R.string.common.confirmTitle(),
                                              message: R.string.mapView.inputTitleMessage(),
                                              preferredStyle: .alert)
                self?.inputFor(alert: alert)
                    .subscribe({ event in
                        // 値が取得できなら、まずはアラートを閉じる(逐一閉じないと、次のアラートが表示できなくなるため)
                        alert.dismiss(animated: false, completion: nil)

                        guard let element = event.element else { return }
                        let alertActionType: AlertActionType = element.0
                        let dataTitle: String? = element.1
                        switch alertActionType {
                        case .ok:
                            // 位置情報の取得精度, アラートの選択アクション, 入力タイトルをViewModelに伝える
                            Observable.just((locationAccuracy, dataTitle))
                                .bind(to: strongSelf.viewModel.startUpdatingLocation)
                                .disposed(by: strongSelf.disposeBag)
                        case .cancel:
                            break
                        }
                    })
                    .disposed(by: strongSelf.disposeBag)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Drive from ViewModel
    private func driveFromViewModel() {

        // drived from ViewModel
        viewModel.authorized
            .drive()
            .disposed(by: disposeBag)

        viewModel.location
            .drive()
            .disposed(by: disposeBag)

        viewModel.savedLocations
            .drive(onNext: { [weak self] footprints in
                guard let strongSelf = self else { return }
                if strongSelf.mapView.annotations.count > 1 {
                    // userLocationをマップに表示しているので必ずannotationsは1以上になる。既に足跡アノテーションを表示している場合、 count >=2
                    strongSelf.resetSelectedFootView()
                }
                if footprints.count > 0 {
                    strongSelf.putFootprints(footprints)
                }
            })
            .disposed(by: disposeBag)

        viewModel.hideLocations
            .drive(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.resetSelectedFootView()
            })
            .disposed(by: disposeBag)

        viewModel.error
            .drive(onNext: { [weak self] message in
                guard let strongSelf = self, let message = message else { return }
                if message.count == 0 { return }
                let alert = UIAlertController(title: R.string.common.confirmTitle(),
                                              message: message,
                                              preferredStyle: .alert)
                _ = strongSelf.promptFor(alert: alert)
                    .subscribe({ _ in
                        alert.dismiss(animated: false, completion: nil)
                        strongSelf.tabBar.selectedItem = nil
                    })
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Drive to ViewModel
    private func driveToViewModel() {

        searchButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let strongSelf = self else { return }
                // 拡大・縮小の初期化
                let coordinateSpan = strongSelf.defaultCoordinateSpan
                let span = MKCoordinateSpan(latitudeDelta: coordinateSpan, longitudeDelta: coordinateSpan)
                let region = MKCoordinateRegion(center: strongSelf.mapView.centerCoordinate, span: span)
                strongSelf.mapView.region = region
                // マップの中心位置をユーザの現在地に変更
                strongSelf.mapView.setCenter(strongSelf.mapView.userLocation.coordinate, animated: true)
                }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        tabBar.rx.didSelectItem
            .asDriver()
            .drive(onNext: { [weak self] item in
                guard let strongSelf = self else { return }
                strongSelf.didSelectTabBarItem(tag: item.tag)
                }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}

// MARK: - Private Methods
extension MapViewController {

    /// 各タブバーアイテムタップ時の処理
    ///
    /// - Parameter tag: タブバーアイテムのタグ
    private func didSelectTabBarItem(tag: Int) {
        guard let itemTag = TabBarItemTag(rawValue: tag) else { return }
        switch itemTag {
        case .start:
            startUpdatingLocationMode()
        case .stop:
            stopUpdatingLocationMode()
        case .footView:
            showOrHideFootprintMode()
        case .settings:
            showSettingViewMode()
        }
    }
    
    /// Startモードに変更された場合に実行される処理
    private func startUpdatingLocationMode() {
        // 位置情報取得精度の選択ピッカーを表示
        pickerView?.showPickerView()
        // スタートボタンをdisabledに変更
        inactivateStartButton()
    }
    
    /// Stopモードに変更された場合に実行される処理
    private func stopUpdatingLocationMode() {
        // 確認アラートを表示、タブバーの選択表示をnilにする(全て未選択状態にする)
        let alert = UIAlertController(title: R.string.common.confirmTitle(),
                                      message: R.string.mapView.stopUpdatingLocationMessage(),
                                      preferredStyle: .alert)
        self.promptFor(alert: alert)
            .subscribe({ [weak self] event in
                alert.dismiss(animated: false, completion: nil)
                
                guard let strongSelf = self, let alertActionType = event.element else { return }
                switch alertActionType {
                case .ok:
                    // タブバーの全アイテムを未選択の状態にする
                    strongSelf.tabBar.selectedItem = nil
                    // ストップボタンをdisabledに変更
                    strongSelf.activateStartButton()
                    // 位置情報の取得停止をViewModelにバインディング
                    Observable.just(Void())
                        .bind(to: strongSelf.viewModel.stopUpdatingLocation)
                        .disposed(by: strongSelf.disposeBag)
                case .cancel:
                    // タブバーの選択状態をスタートボタンの選択状態に戻す
                    let startTag = TabBarItemTag.start
                    strongSelf.tabBar.selectedItem = strongSelf.tabBar.items?[startTag.rawValue]
                }
            })
            .disposed(by: disposeBag)
    }

    /// 足跡の表示/非表示を設定する処理
    private func showOrHideFootprintMode() {

        Observable.just(Void())
            .bind(to: viewModel.showOrHideSavedLocations)
            .disposed(by: disposeBag)
    }

    /// 設定画面を表示する処理
    private func showSettingViewMode() {

        navigateToSetting()
    }
    
    /// マップに足跡をプロットする処理
    ///
    /// - Parameter footprints: 足跡データ
    private func putFootprints(_ footprints: [Footprint]) {
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
            self.mapView.addAnnotation(ann)
        }
    }

    /// タブバーでFOOT VIEWが選択されている状態を解除する処理
    /// FOOT VIEWの選択解除時にプロットしたアノテーションを全て削除する
    private func resetSelectedFootView() {
        tabBar.selectedItem = nil
        mapView.removeAnnotations(mapView.annotations)
    }
    
    /// スタートボタンの有効化&ストップボタンの無効化
    private func activateStartButton() {
        tabBar.items?[TabBarItemTag.start.rawValue].isEnabled = true
        tabBar.items?[TabBarItemTag.stop.rawValue].isEnabled = false
    }
    
    /// スタートボタンの無効化&ストップボタンの有効化
    private func inactivateStartButton() {
        tabBar.items?[TabBarItemTag.start.rawValue].isEnabled = false
        tabBar.items?[TabBarItemTag.stop.rawValue].isEnabled = true
    }

    /// 設定画面に遷移
    private func navigateToSetting() {
        let viewController = SettingViewController.make()
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.tabBar.selectedItem = nil
        }
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        var image = R.image.footprint()
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: R.string.mapView.pinIdentifier())
        annotationView = annotationView
            ?? MKAnnotationView(annotation: annotation, reuseIdentifier: R.string.mapView.pinIdentifier())

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

// MARK: - UITabBarDelegate
extension MapViewController: UITabBarDelegate {
    
}
