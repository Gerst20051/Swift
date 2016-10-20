//
//  ViewController.swift
//  HelloWorldApp
//
//  Created by Andrew Gerst on 8/20/14.
//  Copyright (c) 2014 Andrew Gerst. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var nameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func helloWorldAction(textFieldValue: UITextField) {
        nameLabel.text = "Hi \(textFieldValue.text)"
    }

}
