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
    private var productsDictionary = [[String: Any]]() // the dictionary of products returned in case of "status": "SUCCES" from "products: [ { "title": String, "date": Int } ] etc.

    // MARK: - Overrides
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: Constants.productTableViewCellId, bundle: nil), forCellReuseIdentifier: Constants.productCellId)
        spinner.startAnimating()
        downloadProductList()
        spinner.stopAnimating()
    }

    // MARK: - Function Download
    private func downloadProductList() {

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
                    do {
                        guard let httpDataStatusResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                            print("Data serialization error: Unexpected format received!")
                            return
                        }
                            // SUCCESS
                            if httpDataStatusResponse["status"] as? String == "SUCCESS" {
                                do {
                                    // or maybe httpDataStatusResponse["status"] de products?
                                    guard let httpPorductDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { // [ { "title" : "tags"}
                                        print("Data serialization error: Unexpected format received")
                                        return
                                    }
                                    self.productsDictionary = httpPorductDictionary["products"] as! [[String : Any]]

                                    // FIXME: or maybe Data(httpProductDictionary)? Or a function to encode? check: https://www.codegrepper.com/code-examples/swift/swift+convert+dictionary+to+data
                                    //self.products =  try self.codableDeserialization(for: self.productsDictionary)

                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                    }
                                    print(self.productsDictionary)

                                } catch {
                                    print("Data serialization error: \(error)")
                                }
                                // FAIL
                            } else if httpDataStatusResponse["status"] as? String == "FAILED" {
                                print("Status: FAILED, error message: \(httpDataStatusResponse["messsage"] ?? "empty, no message")")
                            }

                    } catch {
                        print("Data serialization error: \(error)")
                    }

                } else {
                    print("Request error received:  Unexpected condition")
                }
            }
            task.resume()
        }
    }

    func codableDeserialization(for data: Data) throws -> [Product] {
        let jsonDecoder = JSONDecoder()
        let products = try jsonDecoder.decode([Product].self, from: data)
        return products
    }

//    func productsDeserialization(for products: [[String: Any]]) throws -> [Product] {
//        let jsonDecoder = JSONDecoder()
//        let productsList = try jsonDecoder.decode([Product].self, from: products)
//        return productsList
//    }

}

// MARK: extension TableView DELEGATE
extension ProductsViewController: UITableViewDelegate {
    // 1 column
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // FIXME: products.count instead of 0
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsDictionary.count
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

        let item = productsDictionary[indexPath.row]

        productCell.productTile.text = item["title"] as? String
        productCell.productDescription.text = item["description"] as? String

        let separatedTags = item["tags"] as? [String] ?? [""]
        if separatedTags != [""] {
            let joinedTags = separatedTags.joined(separator: ", ") // separating tags with ","
            productCell.productTag.text = joinedTags
        }
        // productCell.productImage.image = ...
        // productCell.prodctDate.date = ...
        return productCell
    }


    // maybe in prepeare for segue
}
