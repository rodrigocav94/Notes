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
