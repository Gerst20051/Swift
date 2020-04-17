//
//  GridAndSolutions.swift
//  GlobalWordRacer
//
//  Created by Andrew Gerst on 4/17/20.
//  Copyright © 2020 Andrew Gerst. All rights reserved.
//

import Foundation

struct GridAndSolutions: Decodable {

    var grid: [[String]]
    var solutions: [String]

    enum CodingKeys: String, CodingKey {
        case grid
        case solutions
    }

}
