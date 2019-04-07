//
//  ViewController.swift
//  SwiftyHUD
//
//  Created by code4archer@163.com on 03/21/2019.
//  Copyright (c) 2019 code4archer@163.com. All rights reserved.
//

import UIKit
import SwiftyHUD

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    @IBAction func showHUD(_ sender: Any) {
        SwiftyHUD.show()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

