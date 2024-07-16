//
//  NoteController.swift
//  Notes
//
//  Created by Rodrigo Cavalcanti on 12/07/24.
//

import UIKit

class NoteController: UIViewController {
    var vm: HomeViewModel?
    var noteIndex: IndexPath?
    var selectedNote: Note? {
        if let noteIndex {
            return vm?.sections[noteIndex.section].notes[noteIndex.row]
        }
        return nil
    }
    var textView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        guard let vm, let noteIndex else { return }
        textView?.text = vm.sections[noteIndex.section].notes[noteIndex.row].text
        updateAttributedString()
        subscribeToKeyboardEvents()

    }
    
    func subscribeToKeyboardEvents() {
        let notificationCenter = NotificationCenter.default // Get a reference to the default notification center.

        notificationCenter.addObserver(
            self, // The object that should receive notifications (it's self)
            selector: #selector(adjustForKeyboard), // The method that should be called
            name: UIResponder.keyboardWillHideNotification, // The notification we want to receive
            object: nil // The object we want to watch. Nil means "we don't care who sends the notification."
        )
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func loadView() {
        let textView = UITextView()
        textView.isScrollEnabled = true
        textView.keyboardDismissMode = .interactive
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

        let deleteAction = UIAction(title: "Remove", image: UIImage(systemName: "trash"), attributes: .destructive, handler: onDeleteTapped)
        let newEntryAction = UIAction(title: "New Entry", image: UIImage(systemName: "square.and.pencil"), handler: onNewEntryTapped)
        let menu = UIMenu(children: [newEntryAction, deleteAction])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
        
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    func onDeleteTapped(_ action: UIAction) {
        let ac = UIAlertController(
            title: "Remove note?",
            message: "This action cannot be undone",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
            self?.textView?.text = ""
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func onNewEntryTapped(_ action: UIAction) {
        updateCurrentNote()
        textView?.text = ""
        noteIndex = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateCurrentNote()
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateCurrentNote() {
        guard let text = textView?.text else { return }
        if text.isEmpty {
            vm?.notes.removeAll(where: {
                $0.id == selectedNote?.id
            })
        } else {
            if let selectedNote {
                let savedText = selectedNote.text
                let updatedText = textView?.text ?? ""
                
                if let noteIndex = vm?.notes.firstIndex(of: selectedNote), savedText != updatedText {
                    vm?.notes[noteIndex].text = updatedText
                    vm?.notes[noteIndex].date = Date()
                }
            } else {
                vm?.notes.insert(Note(text: textView?.text ?? ""), at: 0)
            }
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return } // UIResponder.keyboardFrameEndUserInfoKey tells us the frame of the keyboard after it has finished animating. This will be of type NSValue, which in turn is of type CGRect. The CGRect struct holds both a CGPoint and a CGSize, so it can be used to describe a rectangle.
        guard let textView else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue // pulling out the correct frame of the keyboard
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window) // Converting the rectangle to our view's co-ordinates. Convert() is used to be make sure it works on landscape too.
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset.bottom = 0
        } else {
            textView.contentInset.bottom = keyboardViewEndFrame.height - view.safeAreaInsets.bottom //  indent the edges of our text view so that it appears to occupy less space even though its constraints are still edge to edge in the view.
        }
        
        // scroll so that the text entry cursor is visible. If the text view has shrunk this will now be off screen, so scrolling to find it again keeps the user experience intact.
        textView.scrollIndicatorInsets = textView.contentInset // Scroll indicator insets control how big the scroll bars are relative to their view.
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
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
