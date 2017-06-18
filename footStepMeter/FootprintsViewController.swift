//
//  FootprintViewController.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/06/10.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit

class FootprintsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    private var footprintManager: FootprintManager?
    private var footprintTitles: [String]? = [String]()
    private var footprintCounts: [Int]? = [Int]()
    private var selectedRowTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // RealmSwift関連の初期化処理
        self.footprintManager = FootprintManager.init()
        
        if let footprintHistory = self.footprintManager?.distinctByTitle() {
            for key in footprintHistory.keys {
                footprintTitles?.append(key)
            }
            for value in footprintHistory.values {
                footprintCounts?.append(value)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択時にハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        self.selectedRowTitle = cell?.textLabel?.text
        
        performSegue(withIdentifier: "historyViewSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 指定した足跡のデータを削除
            self.footprintManager?.delete((self.footprintTitles?[indexPath.row])!)
            // 配列から該当の要素を削除
            self.footprintTitles?.remove(at: indexPath.row)
            self.footprintCounts?.remove(at: indexPath.row)
            // テーブルからの削除
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.footprintTitles?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "FootprintHistoryCell", for: indexPath)
        cell.textLabel?.text = self.footprintTitles?[indexPath.row]
        cell.detailTextLabel?.text = "Footprint Count: \(String(describing: (self.footprintCounts?[indexPath.row])!))"
        
        return cell
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "historyViewSegue" {
            if let historyViewController: HistoryViewController = segue.destination as? HistoryViewController {
                historyViewController.historyTitle = self.selectedRowTitle
            }
        }
    }
    
    // MARK: Button Action
    @IBAction func deleteAllFootprints(_ sender: Any) {
        if tableView.numberOfRows(inSection: 0) > 0 {
            // 削除対象がある場合
            // 保存した全ての足跡を削除する処理
            self.footprintManager?.deleteAll()
            self.footprintTitles = nil
            self.footprintCounts = nil
            self.tableView.reloadData()
        } else {
            // 削除対象がない場合
            self.showAlert(title: "Alert", message: "There are no data to delete.", completion: {})
        }
    }
    
    @IBAction func unwindToFootprints(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: Other
    /**
     警告モーダルの表示処理
     
     - parameter title: アラートのタイトル
     - parameter message: アラートのメッセージ
     - parameter completion: OKタップ時のCallback
     */
    private func showAlert(title: String, message: String, completion: @escaping (() -> Void)) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default) { _ in
            completion()
        }
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}
