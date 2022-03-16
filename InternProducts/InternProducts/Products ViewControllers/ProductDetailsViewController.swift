//
//  ProductDetailsViewController.swift
//  InternProducts
//
//  Created by Rona Bompa on 14.03.2022.
//

import UIKit

///
/// Product Details View Controller
///
class ProductDetailsViewController: UIViewController {
    
    public var productDetail = ProductDetail()
    
    // MARK: - Outlets
    
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productDescription: UITextView!
    @IBOutlet weak var productTags: UILabel!
    
    
    // MARK: - Button Actions
    ///
    /// Close
    ///
    @IBAction func closeButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - Overrides
    ///
    /// View Did Load
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        productTitle.text = productDetail.title
        productDescription.text = productDetail.description
        productTags.text = productDetail.tags
        productImage.image = productDetail.image
    }
}
