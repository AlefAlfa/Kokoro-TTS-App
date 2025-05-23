//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Lev on 21.03.25.
//

import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard
            let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = extensionItem.attachments?.first else {
            close()
            return
        }
        
        let textDataType = UTType.plainText.identifier
        if itemProvider.hasItemConformingToTypeIdentifier(textDataType) {
            itemProvider.loadItem(forTypeIdentifier: textDataType) { (providedText, error) in
                if let error {
                    print("Error: \(error.localizedDescription)")
                    self.close()
                    return
                }
               if let text = providedText as? String {
                   print(text)
               } else {
                   print("Something went wrong")
                   self.close()
                   return
               }
            }
        }
        
        close()
    }
    
    private func close() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
