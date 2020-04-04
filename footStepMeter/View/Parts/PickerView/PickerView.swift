//
//  PickerView.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/05/28.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit

/// ピッカービュー
public class PickerView: UIView {

    // MARK: - IBOutlets
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var picker: UIPickerView!

    // MARK: - Static Properties
    static private let screenWidth = UIScreen.main.bounds.size.width
    static private let screenHeight = UIScreen.main.bounds.size.height
    static private let defaultPickerHeight: CGFloat = 260.0
    static private let duration = 0.2

    // MARK: - Properties
    public weak var delegate: PickerViewDelegate?
    private var selectItems = [String]()
    private var selectedRowIndex: Int = 0

    // MARK: - Initial Methods
    required init(frame: CGRect = CGRect(x: 0, y: screenHeight, width: screenWidth, height: defaultPickerHeight),
                  selectItems: [String]) {
        var frame = frame
        if let safeAreaTopInsets = UIApplication.shared.keyWindow?.safeAreaInsets.top, safeAreaTopInsets >= CGFloat(44.0) {
            // iPhoneX , XS, XS MAX, XRの場合はUIPickerViewの高さを調整する
            frame = CGRect(x: 0, y: frame.origin.y, width: frame.size.width, height: (frame.size.height + 100.0))
        }
        super.init(frame: frame)
        self.selectItems = selectItems
        self.xibViewSet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.xibViewSet()
    }
    
    internal func xibViewSet() {
        if let view = R.nib.pickerView.firstView(owner: self) {
            view.frame = self.bounds
            self.addSubview(view)

            picker.delegate = self
            picker.dataSource = self
            picker.showsSelectionIndicator = true
        }
    }

    // MARK: - Picker Move Function
    // PickerViewを表示する
    func showPickerView() {
        let pickerViewWidth = self.frame.size.width
        let pickerViewHeight = self.frame.size.height
        let pickerViewYPosition = PickerView.screenHeight - pickerViewHeight
        UIView.animate(withDuration: PickerView.duration) {
            self.frame = CGRect.init(x: 0, y: pickerViewYPosition, width: pickerViewWidth, height: pickerViewHeight)
        }
    }
    
    // PickerViewを非表示にする
    func hiddenPickerView() {
        let pickerViewWidth = self.frame.size.width
        let pickerViewHeight = self.frame.size.height
        UIView.animate(withDuration: PickerView.duration) {
            self.frame = CGRect.init(x: 0, y: PickerView.screenHeight, width: pickerViewWidth, height: pickerViewHeight)
        }
    }
    
    // MARK: - IBActions
    @IBAction func cancelSelection(_ sender: Any) {
        delegate?.closePickerView()
        hiddenPickerView()
    }
    
    @IBAction func doneSelection(_ sender: Any) {
        delegate?.selectedItem(index: selectedRowIndex, title: selectItems[selectedRowIndex])
        hiddenPickerView()
    }
}

/// MARK: - UIPickerViewDelegate
extension PickerView: UIPickerViewDelegate {

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selectItems[row]
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRowIndex = row
    }
}

/// MARK: - UIPickerViewDataSource
extension PickerView: UIPickerViewDataSource {

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectItems.count
    }
}

/// MARK: - PickerViewDelegate
@objc
public protocol PickerViewDelegate: class {
    func selectedItem(index: Int, title: String)
    func closePickerView()
}
