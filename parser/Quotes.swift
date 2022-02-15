//
//  Quotes.swift
//  parser
//
//  Created by Vladimir Anisimov on 27.07.2021.
//

import Foundation

struct Quotes: Codable {
    var quote: String
    var author: String
    var category_id: Int = 4
    var subcategory_id: Int = 21
}
