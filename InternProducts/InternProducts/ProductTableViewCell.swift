//
//  ProductTableViewCell.swift
//  InternProducts
//
//  Created by Rona Bompa on 15.03.2022.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    // MARK: - Outlets

    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var productTags: UILabel!
    @IBOutlet weak var productImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
