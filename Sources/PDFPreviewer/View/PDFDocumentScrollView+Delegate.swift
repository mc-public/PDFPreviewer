//
//  PDFDocumentScrollView+Delegate.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/10/7.
//

import Foundation

#if os(iOS)
import UIKit
import PDFKit

/// The protocol that `PDFDocumentScrollView`'s Delegate should conform to.
@objc @MainActor
@available(iOS 16.0, *)
public protocol PDFDocumentScrollViewDelegate {
    
    /// Method called when the main page of the document changes.
    @objc optional
    func documenViewDidChangeMainPage(_ documentView: PDFDocumentScrollView, to pageIndex: Int)
    
    /// Method called when the visible page of the document changes.
    @objc optional
    func documenViewDidChangeVisiblePages(_ documentView: PDFDocumentScrollView)
    
    /// Method called when the zoom scale of the document changes.
    @objc optional
    func documentViewDidZoom(_ documentView: PDFDocumentScrollView, zoomScale: CGFloat, isFinished: Bool)
    
    /// Method called for custom select menu.
    @objc optional
    func documentViewCustomMenuItems() -> [PDFDocumentMenuItem]
}

#endif

