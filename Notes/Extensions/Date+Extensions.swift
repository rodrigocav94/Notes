//
//  Date+Extensions.swift
//  Notes
//
//  Created by Rodrigo Cavalcanti on 15/07/24.
//

import Foundation

extension Date {
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }
}


extension Date {
    static let dayInSeconds: Double = 86400
    
    static let currentYear = {
        var components = Calendar.current.dateComponents([.year], from: Date())
        components.day = 1
        components.month = 1
        return Calendar.current.date(from: components)
    }() ?? Date()
    
    static let today = {
        var components = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        components.hour = 0
        components.minute = 0
        return Calendar.current.date(from: components)
    }() ?? Date()
    
    static let yesterday = {
        var components = Calendar.current.dateComponents([.day, .month, .year], from: Date() - dayInSeconds)
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)
    }() ?? Date()
    
    static let sevenDaysAgo = {
        var components = Calendar.current.dateComponents([.day, .month, .year], from: Date() - (dayInSeconds * 7))
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)
    }() ?? Date()
    
    static let thirtyDaysAgo = {
        var components = Calendar.current.dateComponents([.day, .month, .year], from: Date() - (dayInSeconds * 30))
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)
    }() ?? Date()
}
