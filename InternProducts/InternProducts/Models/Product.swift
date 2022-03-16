//
//  Product.swift
//  InternProducts
//
//  Created by Rona Bompa on 11.03.2022.
//

import Foundation
import UIKit

struct Response: Codable {
    let status: String
    let message: String?
    let products: [Product]?
}

struct Product: Codable {
    let title: String
    let description: String
    let tags: [String]?

    var image: String? //   UIImage? CustomImage?
    var date: Int?
}

