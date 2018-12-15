//
//  UIViewController+Rx.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2018/10/13.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIViewController {

    func promptFor(alert: UIAlertController) -> Observable<AlertActionType> {

        return Observable.create { [unowned self] observer in
            // Cancelボタンの追加
            alert.addAction(UIAlertAction(title: R.string.common.cancel(), style: .cancel) { _ in
                observer.onNext(.cancel)
            })
            // OKボタンの追加
            alert.addAction(UIAlertAction(title: R.string.common.ok(), style: .default) { _ in
                observer.onNext(.ok)
            })

            self.present(alert, animated: true, completion: nil)

            return Disposables.create {
                alert.dismiss(animated: false, completion: nil)
            }
        }
    }

    func inputFor(alert: UIAlertController) -> Observable<(AlertActionType, String?)> {

        return Observable.create { [unowned self] observer in
            // UITextFieldの追加
            alert.addTextField(configurationHandler: { _ in
            })
            // Cancelボタンの追加
            alert.addAction(UIAlertAction(title: R.string.common.cancel(), style: .cancel) { _ in
                observer.onNext((.cancel, nil))
            })
            // OKボタンの追加
            alert.addAction(UIAlertAction(title: R.string.common.ok(), style: .default) { _ in
                guard let text = alert.textFields?.first?.text else {
                    return observer.onNext((.cancel, nil))
                }
                observer.onNext((.ok, text))
            })

            self.present(alert, animated: true, completion: nil)

            return Disposables.create {
                alert.dismiss(animated: false, completion: nil)
            }
        }
    }
}
