//
//  Constants.swift
//  InternProducts
//
//  Created by Rona Bompa on 14.03.2022.
//

import Foundation

///
/// Constants - segue identifiers
///
struct Constants {
    static let okHttpStatusCode = 200
    // segues identifiers
    static let fromProductToProductDetails = "fromProductToProductDetails"
    static let fromLoginToTabBarController = "fromLoginToTabBarController"
    static let fromRegisterToTabBarController = "fromRegisterToTabBarController"
}

///
/// Session Variables - login token
///
struct SessionVariables {
    static var loginToken = ""
}

///
/// Layout Mode - compact or expanded
///
enum LayoutMode: String {
    case compact = "compact"
    case expanded = "expanded"
}
