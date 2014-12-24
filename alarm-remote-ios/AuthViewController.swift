//
//  AuthViewController.swift
//  alarm-remote-ios
//
//  Created by Jason Kusnier on 12/24/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var authTokenField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func donePressed(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let authToken = authTokenField.text
        
        if (!authToken.isEmpty) {
            defaults.setValue(authTokenField.text, forKey: Constants.kDefaultsAuthKey)
        
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
