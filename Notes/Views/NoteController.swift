//
//  NoteController.swift
//  Notes
//
//  Created by Rodrigo Cavalcanti on 12/07/24.
//

import UIKit

class NoteController: UIViewController {
    var vm: HomeViewModel?
    var noteIndex: Int?
    var textView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        guard let vm, let noteIndex else { return }
        textView?.text = vm.notes[noteIndex].text
        updateAttributedString()
    }
    
    override func loadView() {
        let textView = UITextView()
        setupView(textView: textView)
        self.view = textView
        self.textView = textView
    }
    
    func setupView(textView: UITextView) {
        textView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        textView.delegate = self
        textView.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    func setupNavBar() {
        navigationItem.largeTitleDisplayMode = .never

        let deleteAction = UIAction(title: "Erase", image: UIImage(systemName: "trash"), attributes: .destructive, handler: onDeleteTapped)
        let newNoteAction = UIAction(title: "New Entry", image: UIImage(systemName: "square.and.pencil"), handler: onNewNoteTapped)
        let menu = UIMenu(children: [newNoteAction, deleteAction])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
    }
    
    func onDeleteTapped(_ action: UIAction) {
        let ac = UIAlertController(
            title: "Delete note?",
            message: "This action cannot be undone",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
            self?.textView?.text = ""
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func onNewNoteTapped(_ action: UIAction) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let text = textView?.text else { return }
        if text.isEmpty {
            if let noteIndex {
                vm?.notes.remove(at: noteIndex)
            }
        } else {
            if let noteIndex {
                vm?.notes[noteIndex].text = textView?.text ?? ""
            } else {
                vm?.notes.insert(Note(text: textView?.text ?? ""), at: 0)
            }
        }
    }
}

extension NoteController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateAttributedString()
    }
    
    func updateAttributedString() {
        guard let text = self.textView?.text else { return }

        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes(
            [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.label
            ],
            range: NSRange(location: 0, length: text.utf16.count)
        )
        
        let range = text.range(of: "\n")?.lowerBound.utf16Offset(in: text) ?? text.utf16.count
        let firstLineBreakRange = NSRange(location: 0, length: range)
        
        attributedText.addAttribute(
            .font,
            value: UIFont.systemFont(ofSize: 22, weight: .bold),
            range: firstLineBreakRange
        )
        
        textView?.attributedText = attributedText
    }
}

#Preview {
    let vc = NoteController()
    let navController = UINavigationController(rootViewController: vc)
    return navController
}
