//
//  HorizontalProductsViewController.swift
//  InternProducts
//
//  Created by Rona Bompa on 17.03.2022.
//

import UIKit

class ProductsViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!

    // products of the filtered list
    private var products = [Product]()
    // all products from http get request
    private var allProducts = [Product]()

    private var productDetail = ProductDetail()
    var layoutMode = LayoutMode.compact
    private var sortedAsc = true

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var sortButton: UIButton!

    @IBOutlet weak var viewImage: UIView!


    //var noDataLabel: UILabel

    @IBAction func searchTextField(_ sender: UITextField) {
        if let searchedString = searchTextField.text {
            products = (searchedString == "") ? allProducts : allProducts.filter {
                $0.title.contains(searchedString) || $0.description.contains(searchedString) || exactMatch(tags: $0.tags!, searchedString: searchedString)
            }
            if products.isEmpty {
                collectionView.setEmptyMessage("Oups... \n There's nothing to be shown here")
            } else {
                if sortedAsc {
                    products = products.sorted(by: {$0.date! < $1.date!})
                } else {
                    products = products.sorted(by: {$0.date! > $1.date!})
                }
                collectionView.restore()
            }
        }
        collectionView.reloadData()
    }

    ///
    /// func - direct match
    ///
    // FIXME: - make extension
    private func exactMatch(tags: [String], searchedString: String) -> Bool {
        var matchFound = false
        for tag in tags {
            if tag == searchedString {
                matchFound = true
            }
        }
        return matchFound
    }
    ///
    /// Sorting Button Action
    ///
    @IBAction func sortingButtonAction(_ sender: UIButton) {
        // sort  Asc
        if sortedAsc {
            products = products.sorted(by: {$0.date! > $1.date!})
            let imageArrowDesc = UIImage(named: "arrow-desc.png")
            sortButton.setImage(imageArrowDesc, for: .normal)

        } else {
        // sort Dsc
            products = products.sorted(by: {$0.date! < $1.date!})
            let imageArrowAsc = UIImage(named: "arrow-asc.png")
            sortButton.setImage(imageArrowAsc, for: .normal)
        }
        sortButton.imageView?.contentMode = .scaleAspectFit
        sortedAsc = !sortedAsc
        collectionView.reloadData()
    }

    // MARK: - Overrides

    ///
    /// View Did Load
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)

        let imageArrowAsc = UIImage(named: "arrow-asc.png")
        sortButton.setImage(imageArrowAsc, for: .normal)
        sortButton.imageView?.contentMode = .scaleAspectFit

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(UINib(nibName: String(describing: CompactCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CompactCollectionViewCell.self))
        collectionView.register(UINib(nibName: String(describing: ExtendedCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: ExtendedCollectionViewCell.self))

        UserDefaults.standard.set(LayoutMode.compact.rawValue, forKey: "layoutMode")

        httpGetProducts()
    }

    ///
    /// View Will Appear
    ///
    override func viewWillAppear(_ animated: Bool) {

        if UserDefaults.standard.string(forKey: "layoutMode") == LayoutMode.compact.rawValue {
            layoutMode = LayoutMode.compact
        } else {
            layoutMode = LayoutMode.expanded
        }

        changeLayout()
        collectionView.reloadData()
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

                        self.allProducts = productsHttpResponse.sorted(by: {$0.date! < $1.date!})
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

    // FIXME: Extenstion to UIImage or String
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

    // FIXME: Extenstion to UIImage or String
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

    ///
    /// Change Layout acording to
    ///
    private func changeLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
        // compact
        if layoutMode == LayoutMode.compact {
                    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                        layout.scrollDirection = .vertical
                        layout.collectionView?.alwaysBounceVertical = true
                        layout.collectionView?.alwaysBounceHorizontal = false
                        layout.itemSize = CGSize(width: view.frame.width, height: 185)
                    }
        } else {
            // extended
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
                layout.collectionView?.alwaysBounceVertical = false
                layout.collectionView?.alwaysBounceHorizontal = true
                layout.itemSize = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
            }
        }

    }
}

// MARK: - Extensions

///
/// extension CollectionView DELEGATE
///
extension ProductsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }

    ///
    /// Did Select Item At  -  cell clicked
    ///
    ///
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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

///
/// extension CollectionView DATA SOURCE
///
extension ProductsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            // Vertical
        if layoutMode == LayoutMode.compact {
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
extension ProductsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

///
/// extension CollectionView
///
extension UICollectionView {

    // FIXME: implemented isHidden instead of this
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
                messageLabel.text = message
                messageLabel.textColor = .darkGray
                messageLabel.numberOfLines = 0;
                messageLabel.textAlignment = .center;
                messageLabel.font = UIFont(name: "System", size: 15)
                messageLabel.sizeToFit()

                self.backgroundView = messageLabel;
    }

    func restore() {
        self.backgroundView = nil
    }
}
