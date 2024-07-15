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
        let textRemaining = components.first ?? ""
        
        var timeStamp: String
        
        switch date {
        case let date where date > .today:
            timeStamp = "Today"
        case let date where date > .yesterday:
            timeStamp = "Yesterday"
        case let date where date > .sevenDaysAgo:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let shortDate = dateFormatter.string(from: date)
            timeStamp = shortDate
        default:
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            let shortDate = dateFormatter.string(from: date)
            timeStamp = shortDate
        }
        
        
        
        return "\(timeStamp) \(textRemaining)"
    }
}
