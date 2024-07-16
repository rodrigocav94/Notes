//
//  HomeViewModel.swift
//  Notes
//
//  Created by Rodrigo Cavalcanti on 12/07/24.
//

import Foundation

class HomeViewModel {
    var toolbarState = ToolbarState.normal
    var selectedNotes: Set<Note> = []
    var sortingOption: SortingOption = {
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()
        
        if let data = defaults.data(forKey: "SortingOption"),
           let notes = try? decoder.decode(SortingOption.self, from: data) {
            return notes
        }
        return .date
    }() {
        didSet {
            saveSortingOptionToUserDefaults()
        }
    }
    
    private func saveSortingOptionToUserDefaults() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()
        
        guard let data = try? encoder.encode(sortingOption) else { return }
        defaults.setValue(data, forKey: "SortingOption")
    }
    
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
            saveNotesToUserDefaults()
        }
    }
    
    private func saveNotesToUserDefaults() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()
        
        guard let data = try? encoder.encode(notes) else { return }
        defaults.setValue(data, forKey: "Notes")
    }
    
    var sections = [Section]()
    var filteredSections = [Section]()
    var searchText: String = ""
    
    func refreshSections() {
        switch sortingOption {
        case .date:
            let sectionsDict = notes
                .map { note in
                    switch note.date {
                    case let date where date > .today:
                        return ("Today", [note])
                    case let date where date > .yesterday:
                        return ("Yesterday", [note])
                    case let date where date > .sevenDaysAgo:
                        return ("Previous 7 Days", [note])
                    case let date where date > .thirtyDaysAgo:
                        return ("Previous 30 Days", [note])
                    case let date where date < .currentYear:
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
        case .title:
            let sortedNotes = notes.sorted {
                $0.text < $1.text
            }
            self.sections = [Section(notes: sortedNotes)]
        }
    }
    
    func filterNotes(refreshingSections: Bool = false, searchedText: String = String(), callback: @escaping () -> Void) {
        if refreshingSections {
            refreshSections()
        }
        
        if searchedText.isEmpty {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                filteredSections = sections
                callback()
            }
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self]  in
            guard let self else { return }
            
            let filteredSections = sections.compactMap { section in
                var filteredSection = section
                let filteredNotes = section.notes.filter { note in
                    note.text.localizedStandardContains(searchedText)
                }
                filteredSection.notes = filteredNotes
                
                if filteredNotes.count > 0 {
                    return filteredSection
                } else {
                    return nil
                }
            }

            DispatchQueue.main.async { [weak self] in
                self?.filteredSections = filteredSections
                callback()
            }
        }
    }
}
