//
//  ViewController.swift
//  Notes
//
//  Created by Rodrigo Cavalcanti on 12/07/24.
//

import UIKit

class ViewController: UITableViewController {
    let vm = HomeViewModel()
    var notesCountBarButton: UIBarButtonItem!
    let searchBarController = UISearchController(searchResultsController: nil)
    var sortMenu: UIMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupToolbar()
        setSearchBarUI()
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        vm.filteredSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if vm.filteredSections.count > 0 {
            return vm.filteredSections[section].notes.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if vm.filteredSections.count > 0 {
            return vm.filteredSections[section].name
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
        if vm.filteredSections.indices.contains(indexPath.section), vm.filteredSections[indexPath.section].notes.indices.contains(indexPath.row) {
            let note = vm.filteredSections[indexPath.section].notes[indexPath.row]
            cell.textLabel?.text = note.firstLine
            cell.detailTextLabel?.text = note.descriptionLine
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let contextItem = UIContextualAction(style: .destructive, title: "Remove") {  [weak self] (contextualAction, view, boolValue) in
            guard let self else { return }
            
            guard let noteIndex = vm.notes.firstIndex(where: {
                $0.id == self.vm.sections[indexPath.section].notes[indexPath.row].id
            }) else { return }
            
            let willEmptyOutSection: Bool = vm.sections[indexPath.section].notes.count == 1
            vm.notes.remove(at: noteIndex)
            
            vm.filterNotes(refreshingSections: true) {
                if willEmptyOutSection {
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
        contextItem.image = UIImage(systemName: "trash")
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        
        return swipeActions
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if vm.toolbarState == .normal {
            let noteEditionView = NoteController()
            noteEditionView.vm = vm
            noteEditionView.noteIndex = indexPath
            navigationController?.pushViewController(noteEditionView, animated: true)
        } else {
            let selectedNote = vm.filteredSections[indexPath.section].notes[indexPath.row]
            vm.selectedNotes.insert(selectedNote)
            if vm.toolbarState != .someSelected {
                vm.toolbarState = .someSelected
                setupToolbar()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedNote = vm.filteredSections[indexPath.section].notes[indexPath.row]
        vm.selectedNotes.remove(selectedNote)
        if vm.selectedNotes.isEmpty {
            vm.toolbarState = .noSelection
            setupToolbar()
        }
    }
    
    func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Notes"
        
        if vm.toolbarState == .normal {
            let dateEditedAction = UIAction(title: "Default (Date Edited)", handler: onDateOrderTapped)
            let titleAction = UIAction(title: "Title", handler: onTitleOrderTapped)
            
            sortMenu = UIMenu(title: "Sort by", subtitle: vm.sortingOption.description, image: UIImage(systemName: "arrow.up.arrow.down"), options: .singleSelection, children: [dateEditedAction, titleAction])
            updateSortingOption()
            
            let selectAction = UIAction(title: "Select Notes", image: UIImage(systemName: "checkmark.circle"), handler: onSelectTapped)
            let menu = UIMenu(children: [selectAction, sortMenu])
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
            
            updateSortingOption()
        } else {
            let doneAction = UIAction(handler: onDoneEditingTapped)
            navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: doneAction)
        }
    }
    
    func onDoneEditingTapped(_ action: UIAction? = nil) {
        tableView.setEditing(false, animated: true)
        vm.selectedNotes = []
        vm.toolbarState = .normal
        setupToolbar()
        setupNavBar()
    }
    
    func onSelectTapped(_ action: UIAction) {
        tableView.setEditing(true, animated: true)
        vm.toolbarState = .noSelection
        setupToolbar()
        setupNavBar()
    }
    
    func onDateOrderTapped(_ action: UIAction) {
        vm.sortingOption = .date
        sortMenu?.subtitle = vm.sortingOption.description
        updateSortingOption()
        vm.filterNotes(refreshingSections: true) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func onTitleOrderTapped(_ action: UIAction) {
        vm.sortingOption = .title
        sortMenu?.subtitle = vm.sortingOption.description
        updateSortingOption()
        vm.filterNotes(refreshingSections: true) { [weak self] in
            self?.tableView.reloadData()
        }
    }

    func updateSortingOption() {
        sortMenu?.children.forEach { action in
            guard let action = action as? UIAction else {
                return
            }
            
            if action.title == vm.sortingOption.description {
                action.state = .on
            }
        }
    }
    
    func setupToolbar() {
        switch vm.toolbarState {
        case .normal:
            let notesCountLabel = UILabel()
            notesCountLabel.text = "\(vm.notes.count) notes"
            notesCountLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
            notesCountLabel.textColor = .secondaryLabel
            
            let notesCountBarButton = UIBarButtonItem(customView: notesCountLabel)
            self.notesCountBarButton = notesCountBarButton
            
            toolbarItems = [
                UIBarButtonItem(systemItem: .flexibleSpace),
                notesCountBarButton,
                UIBarButtonItem(systemItem: .flexibleSpace),
                UIBarButtonItem(systemItem: .compose, primaryAction: UIAction(handler: onNewNoteTapped)),
            ]
            
            navigationController?.setToolbarHidden(false, animated: false)
        case .noSelection:
            let deleteAllButton = UIBarButtonItem(title: "Remove All", style: .plain, target: self, action: #selector(deleteAll))
            deleteAllButton.isEnabled = !vm.notes.isEmpty
            
            toolbarItems = [
                UIBarButtonItem(systemItem: .flexibleSpace),
                deleteAllButton
            ]
        case .someSelected:
            toolbarItems = [
                UIBarButtonItem(systemItem: .flexibleSpace),
                UIBarButtonItem(title: "Remove", style: .plain, target: self, action: #selector(deleteSelected))
            ]
        }
    }
    
    @objc func deleteAll() {
        let ac = UIAlertController(title: "Remove All Notes?", message: "This action cannot be undone", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Remove All", style: .destructive, handler: { [weak self] _ in
            guard let self else { return }
            vm.notes = []
            vm.filterNotes(refreshingSections: true) { [weak self] in
                self?.tableView.reloadData()
            }
            onDoneEditingTapped()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func deleteSelected() {
        let ac = UIAlertController(title: "Remove Selected Notes?", message: "This action cannot be undone", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Remove Notes", style: .destructive, handler: { [weak self] _ in
            guard let self else { return }
            vm.notes.removeAll {
                self.vm.selectedNotes.contains($0)
            }
            vm.filterNotes(refreshingSections: true) { [weak self] in
                self?.tableView.reloadData()
            }
            onDoneEditingTapped()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func onNewNoteTapped(_ action: UIAction) {
        let newNoteView = NoteController()
        newNoteView.vm = vm
        navigationController?.pushViewController(newNoteView, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm.refreshSections()
        filterAndReloadData()
        if let notesCountLabel = notesCountBarButton?.customView as? UILabel {
            notesCountLabel.text = "\(vm.notes.count) notes"
        }
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    func filterAndReloadData() {
        vm.filterNotes(searchedText: searchBarController.searchBar.searchTextField.text ?? "") { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func setSearchBarUI() {
        searchBarController.searchBar.delegate = self
        searchBarController.obscuresBackgroundDuringPresentation = false
        searchBarController.searchBar.sizeToFit()
        navigationItem.searchController = searchBarController
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterAndReloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = String()
        filterAndReloadData()
    }
    
}

#Preview {
    UIStoryboard(
        name: "Main",
        bundle: nil
    )
    .instantiateInitialViewController()!
}
