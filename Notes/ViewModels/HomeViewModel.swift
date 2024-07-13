//
//  HomeViewModel.swift
//  Notes
//
//  Created by Rodrigo Cavalcanti on 12/07/24.
//

import Foundation

class HomeViewModel {
    var notes: [Note] = {
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()
        
        if let data = defaults.data(forKey: "Notes"),
           let notes = try? decoder.decode([Note].self, from: data) {
            return notes
        }
        return []
    }() {
        didSet {
            saveToUserDefaults()
        }
    }
    
    private func saveToUserDefaults() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()
        
        guard let data = try? encoder.encode(notes) else { return }
        defaults.setValue(data, forKey: "Notes")
    }
}
