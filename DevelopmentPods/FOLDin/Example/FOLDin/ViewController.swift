//
//  ViewController.swift
//  FOLDin
//
//  Created by code4archer@163.com on 03/25/2019.
//  Copyright (c) 2019 code4archer@163.com. All rights reserved.
//

import UIKit
import FOLDin

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc = FDDatePickerController()
        present(vc, animated: true) {
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

