//
//  PickerView.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/05/28.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit

class PickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var picker: UIPickerView!
    weak var delegate: PickerViewDelegate?
    private let screenHeight = UIScreen.main.bounds.size.height
    private let duration = 0.2
    private let accuracyArray: [Int: String] = [0: "最高精度", 1: "高精度", 2: "10m誤差", 3: "100m誤差", 4: "1km誤差" , 5: "3km誤差"]
    private var selectedRow: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibViewSet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.xibViewSet()
    }
    
    internal func xibViewSet() {
        let view = Bundle.main.loadNibNamed("PickerView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        picker.delegate = self
        picker.dataSource = self
    }
    
    // MARK: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return accuracyArray.count
    }
    
    // MARK: UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        selectedRow = row
        return accuracyArray[row]
    }
    
    // MARK: Picker Move Function
    // PickerViewを表示する
    func showPickerView() {
        let pickerViewSize = self.frame.size
        UIView.animate(withDuration: duration) {
            self.frame = CGRect.init(x: 0, y: (self.screenHeight - pickerViewSize.height), width: pickerViewSize.width, height: pickerViewSize.height)
        }
    }
    
    // PickerViewを非表示にする
    func hiddenPickerView() {
        let pickerViewSize = self.frame.size
        UIView.animate(withDuration: duration) {
            self.frame = CGRect.init(x: 0, y: self.screenHeight, width: pickerViewSize.width, height: pickerViewSize.height)
        }
    }
    
    // MARK: ToolBar Action
    @IBAction func cancelSelection(_ sender: Any) {
        hiddenPickerView()
    }
    
    @IBAction func doneSelection(_ sender: Any) {
        delegate?.selectedAccuracy(selectedIndex: selectedRow)
        hiddenPickerView()
    }
}

protocol PickerViewDelegate: class {
    func selectedAccuracy(selectedIndex: Int)
}
