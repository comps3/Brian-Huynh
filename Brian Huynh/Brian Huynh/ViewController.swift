//
//  ViewController.swift
//  Brian Huynh
//
//  Created by Brian Huynh on 4/19/15.
//  Copyright (c) 2015 Brian Huynh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the navigation bar color to dark gray
        navigationController?.navigationBar.barTintColor = UIColor.darkGrayColor()
        // Set the navigation bar text color to white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

