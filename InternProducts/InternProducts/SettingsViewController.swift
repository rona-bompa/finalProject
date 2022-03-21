//
//  SettingsViewController.swift
//  InternProducts
//
//  Created by Rona Bompa on 16.03.2022.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0: UserDefaults.standard.set(LayoutMode.compact.rawValue, forKey: "layoutMode")
        case 1: UserDefaults.standard.set(LayoutMode.expanded.rawValue, forKey: "layoutMode")
        default: break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
    }

}
