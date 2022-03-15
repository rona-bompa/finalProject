//
//  ProductsViewController.swift
//  InternProducts
//
//  Created by Rona Bompa on 14.03.2022.
//

import UIKit

class ProductsViewController: UIViewController {

    // MARK: - Overrides
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Outlets

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

}

extension ProductsViewController: UITableViewDelegate {
    // 1 column
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // FIXME: products.count instead of 0
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}

extension ProductsViewController: UITableViewDataSource {

    // FIXME: Here
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
