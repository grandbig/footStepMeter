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

        bindFromViewModel()
        bindToViewModel()
        driveFromViewModel()
        driveToViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Private Methods
extension MapViewController {

    // MARK: - Bind from ViewModel
    private func bindFromViewModel() {

        viewModel.error
            .bind { [weak self] message in
                guard let strongSelf = self, let message = message else { return }
                if message.count == 0 { return }
                let alert = UIAlertController(title: R.string.common.confirmTitle(),
                                              message: message,
                                              preferredStyle: .alert)
                _ = strongSelf.promptFor(alert: alert)
            }
            .disposed(by: disposeBag)
        
        viewModel.doneUpdatingLocationModeDisabled
            .bind { [weak self] _ in
                guard let strongSelf = self else { return }
                // タブバーの全アイテムを未選択の状態にする
                strongSelf.tabBar.selectedItem = nil
                // ストップボタンをdisabledに変更
                strongSelf.activateStartButton()
            }
            .disposed(by: disposeBag)
        
        viewModel.cancelUpdatingLocationModeDisabled
            .bind { [weak self] _ in
                guard let strongSelf = self else { return }
                // タブバーの選択状態をスタートボタンの選択状態に戻す
                let startTag = TabBarItemTag.start
                strongSelf.tabBar.selectedItem = strongSelf.tabBar.items?[startTag.rawValue]
            }
            .disposed(by: disposeBag)
    }

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
                        guard let element = event.element else { return }
                        let alertActionType: AlertActionType = element.0
                        let dataTitle: String? = element.1
                        // 位置情報の取得精度, アラートの選択アクション, 入力タイトルをViewModelに伝える
                        Observable.just((locationAccuracy, alertActionType, dataTitle))
                            .bind(to: strongSelf.viewModel.startUpdatingLocation)
                            .disposed(by: strongSelf.disposeBag)
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

    // MARK: - Other methods
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
            break
        case .settings:
            break
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
                guard let strongSelf = self, let alertActionType = event.element else { return }
                Observable.just(alertActionType)
                    .bind(to: strongSelf.viewModel.stopUpdatingLocation)
                    .disposed(by: strongSelf.disposeBag)
            })
            .disposed(by: disposeBag)
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
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
}

// MARK: - UITabBarDelegate
extension MapViewController: UITabBarDelegate {
    
}
