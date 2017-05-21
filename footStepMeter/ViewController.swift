//
//  ViewController.swift
//  footStepMeter
//
//  Created by Takahiro Kato on 2017/05/21.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITabBarDelegate {

    @IBOutlet weak var tabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tabBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: UITabBarDelegate
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("item.tag: \(item.tag)")
        switch item.tag {
        case 3:
            performSegue(withIdentifier: "settingsSegue", sender: nil)
        default:
            break;
        }
    }
    
    // MARK: Button Action
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
    }
}
