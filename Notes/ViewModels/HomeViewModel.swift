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
    
    var sections = [Section]()
    
    func refreshSections() {
        let dayInSeconds: Double = 86400
        
        guard let currentYear = {
            var components = Calendar.current.dateComponents([.year], from: Date())
            components.day = 1
            components.month = 1
            return Calendar.current.date(from: components)
        }() else { return }
        
        guard let today = {
            var components = Calendar.current.dateComponents([.day, .month, .year], from: Date())
            components.hour = 0
            components.minute = 0
            return Calendar.current.date(from: components)
        }() else { return }
        
        guard let yesterday = {
            var components = Calendar.current.dateComponents([.day, .month, .year], from: Date() - dayInSeconds)
            components.hour = 0
            components.minute = 0
            components.second = 0
            return Calendar.current.date(from: components)
        }() else { return }
        
        guard let sevenDaysAgo = {
            var components = Calendar.current.dateComponents([.day, .month, .year], from: Date() - (dayInSeconds * 7))
            components.hour = 0
            components.minute = 0
            components.second = 0
            return Calendar.current.date(from: components)
        }() else { return }
        
        guard let thirtyDaysAgo = {
            var components = Calendar.current.dateComponents([.day, .month, .year], from: Date() - (dayInSeconds * 30))
            components.hour = 0
            components.minute = 0
            components.second = 0
            return Calendar.current.date(from: components)
        }() else { return }
        
        let sectionsDict = notes
            .map { note in
                switch note.date {
                case let date where date > today:
                    return ("Today", [note])
                case let date where date > yesterday:
                    return ("Yesterday", [note])
                case let date where date > sevenDaysAgo:
                    return ("Previous 7 Days", [note])
                case let date where date > thirtyDaysAgo:
                    return ("Previous 30 Days", [note])
                case let date where date < currentYear:
                    let year = Calendar.current.dateComponents([.year], from: note.date).year
                    return ("\(year ?? 0)", [note])
                default:
                    return (note.date.month, [note])
                }
            }
        
        let sections = Dictionary(sectionsDict, uniquingKeysWith: { $0 + $1 }).map {
            Section(name: $0.key, notes: $0.value)
        }.sorted {
            guard let firstSectionFirstNote =  $0.notes.first, let secondSectionFirstNote = $1.notes.first else {
                return false
            }
            return firstSectionFirstNote.date > secondSectionFirstNote.date
        }
        
        self.sections = sections
    }
}
