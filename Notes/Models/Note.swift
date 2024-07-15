//
//  Note.swift
//  Notes
//
//  Created by Rodrigo Cavalcanti on 12/07/24.
//

import Foundation

struct Note: Hashable, Codable {
    var id = UUID()
    var date = Date()
    var text: String
    
    var firstLine: String {
        let components = text.components(separatedBy: "\n")
        return components.first ?? ""
    }
    
    var descriptionLine: String {
        var components = text.components(separatedBy: "\n")
        components.removeFirst()
        return components.first ?? ""
    }
}
