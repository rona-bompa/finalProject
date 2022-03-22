//
//  CompactCollectionViewCell.swift
//  InternProducts
//
//  Created by Rona Bompa on 17.03.2022.
//

import UIKit

class CompactCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var productTags: UILabel!
    @IBOutlet weak var productImage: UIImageView!

    // MARK: - Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
