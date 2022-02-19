//
//  ActionViewController.swift
//  Extension
//
//  Created by Ivan Pavic on 17.2.22..
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {
    @IBOutlet var scriptView: UITextView!
    
    var pageTitle = ""
    var pageURL = ""
    var scripts = [Script]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(choosePrewrittenScript))
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) {
                    [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                    }
                }
            }
        }
    }
    
    
    @objc func done() {
        let item = NSExtensionItem()
        let argumet: NSDictionary = ["customJavaScript": scriptView.text]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argumet]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
        
    }
    
    @objc func adjustForKeyboard (notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from:view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scriptView.contentInset = .zero
        } else {
            scriptView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        scriptView.scrollIndicatorInsets = scriptView.contentInset
        
        let range = scriptView.selectedRange
        scriptView.scrollRangeToVisible(range)
    }
    
    @objc func choosePrewrittenScript () {
        let ac = UIAlertController(title: nil , message: "Which prewritten script would you like to use?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Title alert", style: .default) {
            [weak self] _ in
            self?.scriptView.text = "alert(document.title);"
        })
        present (ac, animated: true)
    }

}
