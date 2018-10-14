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

    // MARK: - Initial Methods
    required init(with dependency: Dependency) {
        viewModel = dependency
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods
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

        bind()
        drive()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Private Methods
extension MapViewController {

    private func bind() {

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
                        guard let strongSelf = self, let element = event.element else { return }
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

    private func drive() {

        viewModel.authorized
            .drive()
            .disposed(by: disposeBag)

        viewModel.location
            .drive()
            .disposed(by: disposeBag)

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

    /// 各タブバーアイテムタップ時の処理
    ///
    /// - Parameter tag: タブバーアイテムのタグ
    private func didSelectTabBarItem(tag: Int) {
        guard let itemTag = TabBarItemTag(rawValue: tag) else { return }
        switch itemTag {
        case .start:
            pickerView?.showPickerView()
            // TODO: 確認しにくいので一旦コメントアウト
//            inactivateStartButton()
        case .stop:
            break
        case .footView:
            break
        case .settings:
            break
        }
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
