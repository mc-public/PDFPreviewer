//
//  PDFPreviewerModel+InteractionDelegate.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/10/16.
//

#if os(iOS)
import UIKit

//MARK: - Double Tap And Long Press
extension PDFPreviewerModel {
    /// Class representing touch operations performed by the user on a PDF page.
    public typealias DocumentPosition = PDFDocumentScrollView.PDFDocumentTapPosition
    /// The protocol followed when customizing the context menu and gestures of `PDFPreviewer`.
    public typealias InteractionDelegate = PDFPreviewerInteractionDelegate
}

/// The protocol followed when customizing the context menu and gestures of `PDFPreviewer`.
@objc public protocol PDFPreviewerInteractionDelegate: AnyObject {
    /// Method called when a user double-clicks on a point on the page.
    @objc optional func didDoubleTap(at documentPosition: PDFPreviewerModel.DocumentPosition)
    /// The method called when the user long-presses outside the view in the page.
    ///
    /// - Parameter point: Points in the `PDFPreviewer` view coordinate system.
    @objc optional func showMenuOutsidePages(at point: CGPoint) -> UIMenu
    /// The method called when the user long-presses on a point within the view on the page.
    ///
    /// - Parameter documentPosition: The point on the page the user clicked and the point in the PDF page coordinate system.
    //@objc optional func showMenu(at documentPosition: PDFPreviewerModel.DocumentPosition) -> UIMenu
}

#endif

