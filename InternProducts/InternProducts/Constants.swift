//
//  Constants.swift
//  InternProducts
//
//  Created by Rona Bompa on 14.03.2022.
//

import Foundation

struct Constants {
    
    static let okHttpStatusCode = 200

    /// segues identifiers
    //static let fromRegisterToProducts = "fromRegisterToProducts"
    //static let fromLoginToProducts = "fromLoginToProducts"
    static let fromProductToProductDetails = "fromProductToProductDetails"
    static let fromLoginToTabBarController = "fromLoginToTabBarController"
    static let fromRegisterToTabBarController = "fromRegisterToTabBarController"

    /// identifiers
    static let productTableViewCellId = "ProductTableViewCell"
    static let productCellId = "productCell"
    static let compactCollectionViewCell = "compactCollectionViewCell"
    static let extendedCollectionViewCell = "extendedCollectionViewCell"

    /// loginToken
    static var loginToken = ""

}
