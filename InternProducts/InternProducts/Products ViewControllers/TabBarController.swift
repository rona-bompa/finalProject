//
//  TabBarViewController.swift
//  InternProducts
//
//  Created by Rona Bompa on 17.03.2022.
//

import UIKit

class TabBarController: UITabBarController {

    ///
    /// View Did Load
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
}
