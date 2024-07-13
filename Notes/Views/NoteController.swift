//
//  NoteController.swift
//  Notes
//
//  Created by Rodrigo Cavalcanti on 12/07/24.
//

import UIKit

class NoteController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func loadView() {
        let textView = UITextView()
        setupView(textView: textView)
        self.view = textView
    }
    
    func setupView(textView: UITextView) {
        textView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        textView.delegate = self
        textView.font = UIFont.preferredFont(forTextStyle: .body)
    }
}

extension NoteController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.attributedText.string

        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes(
            [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.label
            ],
            range: NSRange(location: 0, length: text.utf16.count)
        )
        
        guard let range = text.range(of: "\n")?.lowerBound else { return }
        let firstLineBreakRange = NSRange(location: 0, length: range.utf16Offset(in: text))
        
        attributedText.addAttribute(
            .font,
            value: UIFont.systemFont(ofSize: 22, weight: .bold),
            range: firstLineBreakRange
        )
        
        textView.attributedText = attributedText
    }
}

#Preview {
    let vc = NoteController()
    let navController = UINavigationController(rootViewController: vc)
    return navController
}
