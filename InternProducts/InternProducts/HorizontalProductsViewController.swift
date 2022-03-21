//
//  HorizontalProductsViewController.swift
//  InternProducts
//
//  Created by Rona Bompa on 17.03.2022.
//

import UIKit

class HorizontalProductsViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!

    private var products = [Product]()
    private var productDetail = ProductDetail()
    var layoutMode = SessionVariables.layoutMode
    
    // MARK: - Overrides

    ///
    /// View Did Load
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(UINib(nibName: String(describing: CompactCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CompactCollectionViewCell.self))

        collectionView.register(UINib(nibName: String(describing: ExtendedCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: ExtendedCollectionViewCell.self))

        layoutFlowMode()
        httpGetProducts()
    }



    // MARK: - Functions

    ///
    /// HTTP Get Products
    ///
    private func httpGetProducts() {
        spinner.startAnimating()
        let urlSession = URLSession(configuration: .default)
        if let url = URL(string: "http://localhost:8080/products?loginToken=\(SessionVariables.loginToken)") {

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
                            self.collectionView.reloadData()
                            self.spinner.stopAnimating()
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

// MARK: - Extensions

///
/// extension CollectionView DELEGATE
///
extension HorizontalProductsViewController: UICollectionViewDelegate {

//    func numberOfSections(_ collectionView: UICollectionView) -> Int {
//        return 1
//    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
}

///
/// extension CollectionView DATA SOURCE
///
extension HorizontalProductsViewController: UICollectionViewDataSource {

    // FIXME: - switch in enum, in order not to copy paste
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        /// switching the xib for

            // Vertical
        if self.layoutMode == LayoutMode.compact {
            guard let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CompactCollectionViewCell.self), for: indexPath) as? CompactCollectionViewCell else {
                    print("UI error: Cell dequeue is unexpected instance!")
                    return UICollectionViewCell()
                }
                let item = products[indexPath.row]
                productCell.productTitle.text = item.title
                productCell.productDescription.text = item.description
                productCell.productTags.text = stringArrayToStringWithCommas(item.tags!)
                productCell.productImage.image = convertStringToImage(item.image!)
                return productCell
        } else {
            // Horizontal
            guard let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ExtendedCollectionViewCell.self), for: indexPath) as? ExtendedCollectionViewCell else {
                    print("UI error: Cell dequeue is unexpected instance!")
                    return UICollectionViewCell()
                }
                let item = products[indexPath.row]
                productCell.productTitle.text = item.title
                productCell.productDescription.text = item.description
                productCell.productTags.text = stringArrayToStringWithCommas(item.tags!)
                productCell.productImage.image = convertStringToImage(item.image!)
                return productCell
        }
    }
}


///
/// extension CollectionView FLOW LAYOUT
///
extension HorizontalProductsViewController: UICollectionViewDelegateFlowLayout {

    private func layoutFlowMode() {
        // compact
        if layoutMode == LayoutMode.compact {
                    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                        layout.scrollDirection = .vertical
                        layout.itemSize = CGSize(width: view.frame.width, height: 185)
                    }
        } else {
            // extended
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
                layout.itemSize = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
            }
        }

    }

}