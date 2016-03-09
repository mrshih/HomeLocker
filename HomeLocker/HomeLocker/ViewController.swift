//
//  ViewController.swift
//  HomeLocker
//
//  Created by 施安宏 on 2016/1/30.
//  Copyright © 2016年 shih. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openDoor(sender: UIButton) {
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request(.POST, "http://114.34.167.81/doorHistory.php", parameters: ["code" : "123"], encoding: .URL, headers: headers).response {request, response, data, error in
            print(request)
            print(response)
            print(data)
            print(error)
        }
    }
}

