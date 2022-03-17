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

    private var products = [Product]()
    private var productDetail = ProductDetail()
    
    // MARK: - Overrides
    ///
    /// View Will Appear
    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    ///
    /// View Did Load
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.productTableViewCellId, bundle: nil), forCellReuseIdentifier: Constants.productCellId)
        httpGetProducts()
    }
    
    ///
    /// Prepare for segue
    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.fromProductToProductDetails {
            if let cvc = segue.destination as? ProductDetailsViewController {
                cvc.productDetail = productDetail
            }
        }
    }
    
    // MARK: - Functions
    
    ///
    /// HTTP Get Products
    ///
    private func httpGetProducts() {
        spinner.startAnimating()
        let urlSession = URLSession(configuration: .default)
        if let url = URL(string: "http://localhost:8080/products?loginToken=\(Constants.loginToken)") {
            
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
                    // decoding data
                    let decoder = JSONDecoder()
                    guard let httpResponse = try? decoder.decode(Response.self, from: data) else {
                        print("Data serialization error: Unexpected format received!")
                        return
                    }
                    // if SUCCES, store in products
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
                        // if FAILED, show message
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
    
    ///
    /// Convert String To Image  = converts a base64 String to a UIImage
    ///
    private func convertStringToImage(_ imageString: String) -> UIImage {
        let imageData =  Data(base64Encoded: imageString, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)
        if let imageData = imageData {
            return UIImage(data: imageData)!
        }
        return UIImage()
    }
    
    ///
    /// String Array To String with Commas  = joins strings in array with "," sepparator
    ///
    private func stringArrayToStringWithCommas(_ stringArray: [String]) -> String {
        let separatedTags = stringArray
        if separatedTags != [""] {
            let joinedTags = separatedTags.joined(separator: ", ") // separating tags with ","
            return joinedTags
        }
        return ""
    }
}

// MARK: extension TableView DELEGATE

extension ProductsViewController: UITableViewDelegate {
    ///
    /// Number Of Sections  -  columns
    ///
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    ///
    /// Number Of Rows In Section  - rows
    ///
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    ///
    /// Did Select Row At  -  cell clicked
    ///
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // set productDeail
        let item = products[indexPath.row]
        productDetail.title = item.title
        productDetail.description = item.description
        productDetail.tags = stringArrayToStringWithCommas(item.tags!)
        productDetail.image = convertStringToImage(item.image!)
        
        // segue to productDetailsViewController
        performSegue(withIdentifier: Constants.fromProductToProductDetails, sender: nil)
        
    }
}

// MARK: - Extension TableView DATA SOURCE

extension ProductsViewController: UITableViewDataSource {
    ///
    /// Cell For Row At - load  cell data
    ///
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let productCell = tableView.dequeueReusableCell(withIdentifier: Constants.productCellId, for: indexPath) as? ProductTableViewCell else {
            print("UI error: Cell dequeue is unexpected instance!")
            return UITableViewCell()
        }
        
        let item = products[indexPath.row]
        productCell.productTitle.text = item.title
        productCell.productDescription.text = item.description
        productCell.productTags.text = stringArrayToStringWithCommas(item.tags!)
        productCell.productImage.image = convertStringToImage(item.image!)
        
        return productCell
    }
}
