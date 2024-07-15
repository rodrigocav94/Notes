//
//  SortingOption.swift
//  Notes
//
//  Created by Rodrigo Cavalcanti on 15/07/24.
//

import Foundation

enum SortingOption: Codable {
    case date, title
    
    var description: String {
        switch self {
        case .date:
            return "Default (Date Edited)"
        case .title:
            return "Title"
        }
    }
}
