//
//  SettingsViewController.swift
//  InternProducts
//
//  Created by Rona Bompa on 16.03.2022.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var segmentedControl: UISegmentedControl!


    // MARK: - Button Action

    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0: UserDefaults.standard.set(LayoutMode.compact.rawValue, forKey: "layoutMode")
        case 1: UserDefaults.standard.set(LayoutMode.expanded.rawValue, forKey: "layoutMode")
        default: break
        }
    }

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
    }

}
