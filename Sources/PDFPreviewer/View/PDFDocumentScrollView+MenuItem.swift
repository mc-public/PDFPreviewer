//
//  PDFDocument+MenuItem.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/10/15.
//

#if canImport(UIKit)
import UIKit
/// Custom menu items when selecting in a `PDFDocumentScrollView`.
///
/// The menu items will be displayed in the pop-up menu after the user long-presses and selects.
@objc
public final class PDFDocumentMenuItem: NSObject {
    
    let _actionHandle: @MainActor (PDFDocumentScrollView, PDFDocumentModel) -> Void
    let title: String
    let icon: UIImage?
    
    /// Construct menu items with specified title and icon.
    ///
    /// - Parameter title: The title of the menu item.
    /// - Parameter icon: The icon of the menu item.
    /// - Parameter handle: Closure executed after clicking the menu item.
    public init(title: String, icon: UIImage? = nil, handle: @escaping @MainActor (PDFDocumentScrollView, PDFDocumentModel) -> Void) {
        self.title = title
        self._actionHandle = handle
        self.icon = icon
        super.init()
    }
    
    @MainActor func actionHandle(view: PDFDocumentScrollView, document: PDFDocumentModel) {
        self._actionHandle(view, document)
    }
}

#endif
