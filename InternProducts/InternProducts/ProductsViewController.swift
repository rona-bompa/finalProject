//
//  ProductsViewController.swift
//  InternProducts
//
//  Created by Rona Bompa on 14.03.2022.
//

import UIKit

class ProductsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    // FIXME: Some level of privacy for loginToken
    var loginToken = ""
    private var products = [Product]()
    //private var productsDictionary = [[String: Any]]() // the dictionary of products returned in case of "status": "SUCCES" from "products: [ { "title": String, "date": Int } ] etc.

    // MARK: - Overrides
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.productTableViewCellId, bundle: nil), forCellReuseIdentifier: Constants.productCellId)
        downloadProductList()
    }

    // MARK: - Function Download
    private func downloadProductList() {
        spinner.startAnimating()
        let urlSession = URLSession(configuration: .default)
        if let url = URL(string: "http://localhost:8080/products?loginToken=\(loginToken)") {

            let task = urlSession.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                /// error
                if let error = error {
                    print("Request error received: \(error)")
                /// response
                } else if let response = response as? HTTPURLResponse, response.statusCode != Constants.okHttpStatusCode {
                        print("Expected 200 status code, but received: \(response.statusCode)")
                /// data
                } else if let data = data {

                    let decoder = JSONDecoder()
                    guard let httpResponse = try? decoder.decode(Response.self, from: data) else {
                        print("Data serialization error: Unexpected format received!")
                        return
                    }

                    if httpResponse.status == "SUCCESS" {
                        guard let productsHttpResponse = httpResponse.products else {
                            print("No products returned")
                            return
                        }

                        self.products = productsHttpResponse.sorted(by: {$0.date! < $1.date!}) // sorted by date

                        DispatchQueue.main.async {
                            self.spinner.stopAnimating()
                            self.tableView.reloadData()
                        }
                    } else if httpResponse.status == "FAILED" {
                        print("Status: FAIED; Message: \(httpResponse.message!)")
                    }

                } else {
                    print("Request error received:  Unexpected condition")
                }
            }
            task.resume()
        }
    }
}

// MARK: extension TableView DELEGATE
extension ProductsViewController: UITableViewDelegate {
    // 1 column
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
}

// MARK: - Extension TableView DATA SOURCE
extension ProductsViewController: UITableViewDataSource {

    // FIXME: Here
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let productCell = tableView.dequeueReusableCell(withIdentifier: Constants.productCellId, for: indexPath) as? ProductTableViewCell else {
            print("UI error: Cell dequeue is unexpected instance!")
            return UITableViewCell()
        }

        let item = products[indexPath.row]

        productCell.productTitle.text = item.title
        productCell.productDescription.text = item.description

        let separatedTags = item.tags
        if separatedTags != nil { // sau [""]?
            let joinedTags = separatedTags!.joined(separator: ", ") // separating tags with ","
            productCell.productTags.text = joinedTags
        }

//        let imageData = Data(base64Encoded: item.image!)
//        if let imageData = imageData {
//            productCell.productImage.image = UIImage(data: imageData)
//        }
        return productCell
    }
    // maybe in prepeare for segue
}
