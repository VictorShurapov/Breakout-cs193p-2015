//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Victor Shurapov on 3/14/18.
//  Copyright © 2018 Victor Shurapov. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController {

    @IBOutlet weak var breakoutView: BreakoutView! {
        didSet {
            breakoutView.initialize()
        }
    }
    
    @IBOutlet weak var ballsLeftLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
