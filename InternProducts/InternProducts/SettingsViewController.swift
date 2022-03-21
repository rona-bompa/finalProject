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

    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
           // layoutMode = Constants.LayoutMode.compact
            break
        case 1:
           // HorizontalProductsViewController.layoutMode = Constants.LayoutMode.expanded
            break
        default: break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
    }

}
