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
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var sortButton: UIButton!
    var messageLabel = UILabel()
    
    
    // MARK: - Variables
    
    private let httpService = HTTPService()
    /// products of the filtered list
    private var products = [Product]()
    /// all products from http get request
    private var allProducts = [Product]()
    /// productDetail to be shown in ProductDetailsViewController
    private var productDetail = ProductDetail()
    
    var layoutMode = LayoutMode.compact
    private var sortedAsc = true
    
    let imageArrowAsc = UIImage(named: "arrow-asc.png")
    let imageArrowDesc = UIImage(named: "arrow-desc.png")
    
    // MARK: - Actions - filter & sort
    ///
    ///  Search TextField Action
    ///
    @IBAction func searchTextField(_ sender: UITextField) {
        if let searchedString = searchTextField.text {
            products = (searchedString == "") ? allProducts : allProducts.filter {
                $0.title.contains(searchedString) ||
                $0.description.contains(searchedString) ||
                $0.tags!.containsExactMatchToElement(element: searchedString)
            }
            if products.isEmpty {
                messageLabel.isHidden = false
            } else {
                if sortedAsc {
                    products = products.sorted(by: {$0.date! < $1.date!})
                } else {
                    products = products.sorted(by: {$0.date! > $1.date!})
                }
                messageLabel.isHidden = true
            }
        }
        collectionView.reloadData()
    }
    
    ///
    /// Sorting Button Action
    ///
    @IBAction func sortingButtonAction(_ sender: UIButton) {
        // sort  Asc
        if sortedAsc {
            products = products.sorted(by: {$0.date! > $1.date!})
            sortButton.setImage(imageArrowDesc, for: .normal)
        } else {
            // sort Dsc
            products = products.sorted(by: {$0.date! < $1.date!})
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
        
        // collectionview delegates & register xibs (cells compact & extended)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: String(describing: CompactCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CompactCollectionViewCell.self))
        collectionView.register(UINib(nibName: String(describing: ExtendedCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: ExtendedCollectionViewCell.self))
        
        // init image button
        sortButton.setImage(imageArrowAsc, for: .normal)
        sortButton.imageView?.contentMode = .scaleAspectFit
        
        // init messageLabel
        initMessageLabel()
        
        // init layout mode
        UserDefaults.standard.set(LayoutMode.compact.rawValue, forKey: "layoutMode")
        
        // http request for products
        getProducts()
    }
    
    ///
    /// View Will Appear
    ///
    override func viewWillAppear(_ animated: Bool) {
        // update layoutMode
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
    /// Get Products
    ///
    private func getProducts() {
        spinner.startAnimating()
        
        httpService.httpGetProducts { httpResultCases, message, products in
            DispatchQueue.main.async {
                switch httpResultCases {
                case .error:
                    print(message)
                case .responseFail:
                    print(message)
                case .dataSuccess:
                    if let products = products {
                        self.allProducts = products.sorted(by: {$0.date! < $1.date!})
                        self.products = products.sorted(by: {$0.date! < $1.date!}) // sorted by date
                    }
                    self.collectionView.reloadData()
                    self.spinner.stopAnimating()
                    
                case .dataFail:
                    print(message)
                }
            }
        }
    }
    
    ///
    /// Init Empty List Message Label
    ///
    private func initMessageLabel() {
        messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
        messageLabel.textColor = .darkGray
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "System", size: 15)
        messageLabel.text = "Oups... \n There's nothing to be shown here"
        messageLabel.sizeToFit()
        messageLabel.isHidden = true
        collectionView.backgroundView = messageLabel;
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

// MARK: - Extensions - Delegate & DataSource & FlowLayout

extension ProductsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // set productDeail
        let item = products[indexPath.row]
        productDetail.title = item.title
        productDetail.description = item.description
        if let tags = item.tags {
            productDetail.tags = tags.stringArrayToStringWithCommas()
        }
        if let imageString = item.image {
            productDetail.image = imageString.convertStringToImage()
        }
        // segue to productDetailsViewController
        performSegue(withIdentifier: Constants.fromProductToProductDetails, sender: nil)
    }
    
}

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
            if let tags = item.tags {
                productCell.productTags.text = tags.stringArrayToStringWithCommas()
            }
            if let stringImage = item.image {
                productCell.productImage.image = stringImage.convertStringToImage()
            }
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
            if let tags = item.tags {
                productCell.productTags.text = tags.stringArrayToStringWithCommas()
            }
            if let stringImage = item.image {
                productCell.productImage.image = stringImage.convertStringToImage()
            }
            return productCell
        }
    }
}

extension ProductsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - Extensions - [String] & String
extension Array where Element == String {
    func containsExactMatchToElement(element: Element) -> Bool {
        var matchFound = false
        self.forEach{ arrayElement in
            if arrayElement == element {
                matchFound = true
            }
        }
        return matchFound
    }
    ///
    /// String Array To String with Commas  = joins strings in array with "," sepparator
    ///
    func stringArrayToStringWithCommas() -> String {
        if self != [""] {
            let joinedTags = self.joined(separator: ", ") // separating tags with ","
            return joinedTags
        }
        return ""
    }
}

extension String {
    ///
    /// Convert String To Image  = converts a base64 String to a UIImage
    ///
    func convertStringToImage() -> UIImage {
        let imageData =  Data(base64Encoded: self, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)
        if let imageData = imageData {
            return UIImage(data: imageData)!
        }
        return UIImage()
    }
}
