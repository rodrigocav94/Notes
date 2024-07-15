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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupToolbar()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        vm.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if vm.sections.count > 0 {
            return vm.sections[section].notes.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if vm.sections.count > 0 {
            return vm.sections[section].name
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
        if vm.sections.indices.contains(indexPath.section), vm.sections[indexPath.section].notes.indices.contains(indexPath.row) {
            let note = vm.sections[indexPath.section].notes[indexPath.row]
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(onMoreTapped))
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
    
    @objc func onMoreTapped() {
        
    }
    
    func onNewNoteTapped(_ action: UIAction) {
        let newNoteView = NoteController()
        newNoteView.vm = vm
        navigationController?.pushViewController(newNoteView, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm.refreshSections()
        tableView.reloadData()
        if let notesCountLabel = notesCountBarButton?.customView as? UILabel {
            notesCountLabel.text = "\(vm.notes.count) notes"
        }
        navigationController?.setToolbarHidden(false, animated: false)
    }
}

#Preview {
    UIStoryboard(
        name: "Main",
        bundle: nil
    )
    .instantiateInitialViewController()!
}
