//
//  ViewController.swift
//  Notes
//
//  Created by Rodrigo Cavalcanti on 12/07/24.
//

import UIKit

class ViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupToolbar()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
        return cell
    }
    
    func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Notes"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(onMoreTapped))
    }
    
    func setupToolbar() {
        let notesCount = UILabel()
        notesCount.text = "10 notes"
        notesCount.font = UIFont.preferredFont(forTextStyle: .subheadline)
        notesCount.textColor = .secondaryLabel
        
        toolbarItems = [
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(customView: notesCount),
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(systemItem: .compose, primaryAction: UIAction(handler: onNewNoteTapped)),
        ]
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    @objc func onMoreTapped() {
        
    }
    
    func onNewNoteTapped(_ action: UIAction) {
        let emptyView = NoteController()
        navigationController?.pushViewController(emptyView, animated: true)
    }
}

#Preview {
    UIStoryboard(
        name: "Main",
        bundle: nil
    )
    .instantiateInitialViewController()!
}
