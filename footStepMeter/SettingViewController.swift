//
//  SettingViewController.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/05/22.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    private let rowTitle = ["Footprint History", "About App", "Licence"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択時にハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "footprintHistorySegue", sender: nil)
        case 1:
            performSegue(withIdentifier: "aboutAppSegue", sender: nil)
        case 2:
            performSegue(withIdentifier: "licenceSegue", sender: nil)
        default:
            break
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rowTitle.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.textLabel?.text = self.rowTitle[indexPath.row]
        
        return cell
    }
    
    // MARK: Button Action
    @IBAction func unwindToSetting(segue: UIStoryboardSegue) {
        
    }
}
