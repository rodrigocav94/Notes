//
//  ViewController.swift
//  Notes
//
//  Created by Rodrigo Cavalcanti on 12/07/24.
//

import UIKit

class ViewController: UITableViewController {
    let vm = HomeViewModel()
    var notesCountBarButton: UIBarButtonItem?
    let searchBarController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupToolbar()
        setSearchBarUI()
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let noteEditionView = NoteController()
        noteEditionView.vm = vm
        noteEditionView.noteIndex = indexPath
        navigationController?.pushViewController(noteEditionView, animated: true)
    }
    
    func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Notes"
        
        let dateEditedAction = UIAction(title: "Default (Date Edited)", handler: onSelectTapped)
        let aToZAction = UIAction(title: "A to Z", handler: onSelectTapped)
        let sortMenu = UIMenu(title: "Sort by", subtitle: "Default (Date Edited)", image: UIImage(systemName: "arrow.up.arrow.down"), options: .singleSelection, children: [dateEditedAction, aToZAction])
        
        let selectAction = UIAction(title: "Select Notes", image: UIImage(systemName: "checkmark.circle"), handler: onSelectTapped)
        let menu = UIMenu(children: [selectAction, sortMenu])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
    }
    
    func onSelectTapped(_ action: UIAction) {

    }
    
    func onOrderTapped(_ action: UIAction) {
        
    }
    
    func setupToolbar() {
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
