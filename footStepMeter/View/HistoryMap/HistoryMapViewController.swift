//
//  HistoryMapViewController.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2019/01/02.
//  Copyright © 2019 Takahiro Kato. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import RxDataSources
import MessageUI

/// 足跡履歴の確認画面
final class HistoryMapViewController: UIViewController, Injectable {
    typealias Dependency = HistoryMapViewModel

    // MARK: - IBOutlets
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var selectableView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var toggleFootprintButton: UIButton!
    @IBOutlet private weak var mailButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!

    // MARK: - Properties
    private let viewModel: HistoryMapViewModel
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<HistoryMapSectionModel>!
    private let defaultCoordinateSpan = 0.05
    private var annotationImage = R.image.footprint()

    // MARK: - Initial methods
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

        let backButton = UIBarButtonItem(title: R.string.common.back(), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backButton

        mapView.delegate = self

        tableView.register(R.nib.customTableViewCell)
        dataSource = RxTableViewSectionedReloadDataSource<HistoryMapSectionModel>(
            configureCell: { _, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.customCellIdentifier,
                                                         for: IndexPath(row: indexPath.row, section: 0))!
                cell.textLabel?.text = item.0
                cell.imageView?.image = item.1
                cell.accessoryType = .disclosureIndicator
                
                return cell
        })

        bindFromViewModel()
        bindToViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Static Methods
extension HistoryMapViewController {

    static func make(title: String) -> HistoryMapViewController {
        let dependency = HistoryMapViewModel.Dependency.init(title: title, realmManager: RealmManager())
        let viewModel = HistoryMapViewModel(with: dependency)
        let historyMapViewController = HistoryMapViewController(with: viewModel)
        return historyMapViewController
    }
}

// MARK: - Private Methods
extension HistoryMapViewController {

    /// モーダルを非表示にする処理
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }

    /// マップの縮図および中心位置の変更
    ///
    /// - Parameters:
    ///   - latitude: 緯度
    ///   - longitude: 軽度
    ///   - coordinateSpan: 縮小値
    private func moveToMapCenterPosition(latitude: Double, longitude: Double, coordinateSpan: Double) {
        // 拡大・縮小の初期化
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: coordinateSpan, longitudeDelta: coordinateSpan)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.region = region
        // 中心位置を移動
        mapView.setCenter(coordinate, animated: true)
    }

    /// ViewModelのObservableを監視
    private func bindFromViewModel() {

        viewModel.viewDidLoadStream
            .asObservable()
            .subscribe(onNext: { [weak self] results in
                guard let strongSelf = self else { return }
                let footprints = results.0
                if footprints.count == 0 { return }
                strongSelf.title = footprints.first?.title
                strongSelf.mapView.putFootprints(footprints)
                if let latitude = footprints.first?.latitude, let longitude = footprints.first?.longitude {
                    strongSelf.moveToMapCenterPosition(latitude: latitude,
                                                       longitude: longitude,
                                                       coordinateSpan: strongSelf.defaultCoordinateSpan)
                }
                Observable.just(results.1)
                    .bind(to: strongSelf.tableView.rx.items(dataSource: strongSelf.dataSource))
                    .disposed(by: strongSelf.disposeBag)
            })
            .disposed(by: disposeBag)

        viewModel.completeSendMailStream
            .asObservable()
            .subscribe(onNext: { [weak self] footprints in
                guard let strongSelf = self else { return }
                if footprints.count == 0 { return }
                strongSelf.sendMailWithCSV(subject: R.string.historyMapView.sendMailSubject(),
                                           message: String(),
                                           footprints: footprints)
            })
            .disposed(by: disposeBag)

        viewModel.completeShowSelectIconStream
            .asObservable()
            .subscribe(onNext: { [weak self] result in
                guard let strongSelf = self else { return }
                if !result { return }
                strongSelf.showOrHideSelectableView()
            })
            .disposed(by: disposeBag)

        viewModel.completeChangeFootprintIconStream
            .asObservable()
            .subscribe(onNext: { [weak self] results in
                guard let strongSelf = self else { return }
                let footprints = results.0
                if footprints.count == 0 { return }
                strongSelf.reputFootprints(footprints: footprints, iconMode: results.1)
            })
            .disposed(by: disposeBag)
    }

    /// ViewModelへのイベント伝達処理
    private func bindToViewModel() {

        mailButton.rx.tap
            .bind(to: viewModel.requestSendMailStream)
            .disposed(by: disposeBag)

        toggleFootprintButton.rx.tap
            .bind(to: viewModel.requestShowSelectIconStream)
            .disposed(by: disposeBag)
    }
    /// 足跡データからCSVファイル形式の文字列を生成する処理
    ///
    /// - Parameter footprints: 足跡データ
    /// - Returns: CSVファイル形式の文字列
    private func makeCSVData(footprints: [Footprint]) -> String {
        var datas: [[String]] = [[R.string.historyMapView.id(),
                                  R.string.historyMapView.latitude(),
                                  R.string.historyMapView.longitude(),
                                  R.string.historyMapView.accuracy(),
                                  R.string.historyMapView.speed(),
                                  R.string.historyMapView.direction(),
                                  R.string.historyMapView.created()]]
        for footprint in footprints {
            let data: [String] = [String(footprint.id),
                                  String(footprint.latitude),
                                  String(footprint.longitude),
                                  String(footprint.accuracy),
                                  String(footprint.speed),
                                  String(footprint.direction),
                                  String(footprint.created)]
            datas.append(data)
        }
        return String.toCSV(datas: datas)
    }

    /// CSVファイルを添付してメールを送信する処理
    ///
    /// - Parameters:
    ///   - subject: タイトル
    ///   - message: メール本文
    ///   - data: データ
    private func sendMailWithCSV(subject: String, message: String, footprints: [Footprint]) {

        let csvData = makeCSVData(footprints: footprints)
        if let encodedData = csvData.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let mailViewController = MFMailComposeViewController()
            mailViewController.mailComposeDelegate = self
            mailViewController.setSubject(subject)
            mailViewController.setMessageBody(message, isHTML: false)
            mailViewController.addAttachmentData(encodedData,
                                                 mimeType: R.string.historyMapView.mimeType(),
                                                 fileName: R.string.historyMapView.fileName())

            let navigationController = UINavigationController(rootViewController: mailViewController)
            present(navigationController, animated: true) {}
        }
    }

    /// マップにアイコンを変更した足跡を再描画
    ///
    /// - Parameters:
    ///   - footprints: 足跡データ
    ///   - iconMode: アイコンモード
    private func reputFootprints(footprints: [Footprint], iconMode: FootprintIconMode) {
        mapView.removeAnnotations(mapView.annotations)

        switch iconMode {
        case .human:
            annotationImage = R.image.footprint()
        case .animal:
            annotationImage = R.image.animalFootprint()
        }

        mapView.putFootprints(footprints)
    }

    private func showOrHideSelectableView() {
        selectableView.isHidden = !selectableView.isHidden
    }
}

// MARK: - MFMailComposeViewControllerDelegate
// TODO: RxSwiftっぽく書き直す
extension HistoryMapViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {

        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - MKMapViewDelegate
extension HistoryMapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: R.string.historyMapView.pinIdentifier())
        annotationView = annotationView
            ?? MKAnnotationView(annotation: annotation, reuseIdentifier: R.string.historyMapView.pinIdentifier())
        
        if let customAnnotation = annotation as? CustomAnnotation {
            let direction = CGFloat(customAnnotation.direction ?? 0)
            annotationImage = annotationImage?.rotate(angle: direction)
        }
        
        annotationView?.image = annotationImage
        annotationView?.annotation = annotation
        annotationView?.canShowCallout = true
        return annotationView
    }
}
