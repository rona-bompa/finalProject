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
    static let fromProductToProductDetails = "fromProductToProductDetails"
    static let fromLoginToTabBarController = "fromLoginToTabBarController"
    static let fromRegisterToTabBarController = "fromRegisterToTabBarController"

    /// identifiers
    static let productTableViewCellId = "ProductTableViewCell"
    static let productCellId = "ProductCell"
}

struct SessionVariables {
    /// loginToken
    static var loginToken = ""

    /// layout mode
    static var layoutMode = LayoutMode.compact
}

enum LayoutMode: String {
    case compact
    case expanded
}

