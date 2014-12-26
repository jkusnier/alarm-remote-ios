//
//  ViewController.swift
//  alarm-remote-ios
//
//  Created by Jason Kusnier on 12/24/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var topToolbarConstraint: NSLayoutConstraint!

    @IBOutlet weak var bottomToolbar: UIToolbar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topToolbarConstraint.constant = UIApplication.sharedApplication().statusBarFrame.height
        
        topToolbar.items = [UIBarButtonItem(title: "Switch", style: .Bordered, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Edit", style: .Bordered, target: nil, action: nil)]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.stringForKey(Constants.kDefaultsAccessTokenKey) == nil) {
            performSegueWithIdentifier("showAuth", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

