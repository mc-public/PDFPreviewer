//
//  PDFPageModel.swift
//
//
//  Created by 孟超 on 2024/9/16.
//
#if os(iOS)
import UIKit
import Foundation
import PDFKit

/// Model representing a page in a `PDFDocumentModel`
///
/// Essentially a subclass of `PDFPage` provided by the `PDFKit` framework.
@available(iOS 15.0, macOS 11.0, *)
public final class PDFPageModel: PDFPage {
    
    @available(*, unavailable)
    override public var document: PDFDocument? {
        super.document
    }
    
    /// Returns the `PDFDocumentModel` object with which the page is associated.
    var documentModel: PDFDocumentModel? {
        super.document as? PDFDocumentModel
    }
    
    /// The overlay of the current page.
    @MainActor
    var overlayView: UIView? {
        guard let pageIndex = self.documentModel?.index(for: self) else {
            return nil
        }
        return self.documentModel?.overlayViews[pageIndex]
    }
    
    /// Initialize an empty page.
    ///
    /// Sets the frame of the `MediaBox` for this page to `(0.0, 0.0), [612.0, 792.0]` upon initialization.
    public override init() {
        super.init()
    }
    
    /// Returns the bounds for the specified PDF display box with specific trim.
    @available(*, unavailable)
    override public func bounds(for box: PDFDisplayBox) -> CGRect {
        let bounds = super.bounds(for: box)
        guard let documentModel else { return bounds }
        let verticalCrop = (bounds.height * 0.5 * documentModel.trimLevel.rawValue / 100)
        let horizontalCrop = (bounds.width * 1.0 * documentModel.trimLevel.rawValue / 100)
        return bounds.inseting(top: verticalCrop, bottom: verticalCrop, left: horizontalCrop, right: horizontalCrop)
    }
    
    /// Returns the bounds for the specified PDF display box.
    public func bounds(box: PDFDisplayBox) -> CGRect {
        super.bounds(for: box)
    }
    
    
    @available(*, unavailable)
    public override func setBounds(_ bounds: CGRect, for box: PDFDisplayBox) {
        super.setBounds(bounds, for: box)
    }
    
    
    
    
#if canImport(UIKit)
    
    /// Initialize a `PDF` page with a specified `UIImage` instance and options.
    ///
    /// Returns `nil` if initialization fails.
    ///
    /// - Parameter image: The `UIImage` instance to be used for initialization.
    /// - Parameter options: The options specified upon initialization.
    @available(iOS 16.0, *)
    public override init?(image: UIImage, options: [PDFPage.ImageInitializationOption : Any] = [:]) {
        super.init(image: image, options: options)
    }
    
#endif
    
    
#if canImport(Cocoa)
    
    /// Initialize a `PDF` page with a specified `UIImage` instance and options
    ///
    /// - Parameter image: The `UIImage` instance to be used for initialization.
    /// - Parameter options: The options specified upon initialization.
    /// - Returns: Returns `nil` if initialization fails.
    @available(macOS 13.0, *)
    public override init?(image: NSImage, options: [PDFPage.ImageInitializationOption : Any] = [:]) {
        super.init(image: image, options: options)
    }
    
#endif
    
    /// Rendering with this method may cause excessive memory usage.
    @available(*, unavailable)
    public override func draw(with box: PDFDisplayBox, to context: CGContext) {
        guard let documentModel else {
            super.draw(with: box, to: context)
            return
        }
        if documentModel.invertRenderingColor && documentModel.userInterfaceStyle == .dark { // dark mode and invert rendering color
            // set fill color
            context.saveGState()
            context.setFillColor(UIColor.white.cgColor)
            context.fill(super.bounds(for: .mediaBox))
            context.restoreGState()
            // draw page
            context.setBlendMode(.destinationAtop)
            super.draw(with: box, to: context)
            context.setBlendMode(.exclusion)
            super.draw(with: box, to: context)
            
        } else if documentModel.userInterfaceStyle == .dark {
            // set fill color
            context.saveGState()
            context.setFillColor(UIColor.clear.cgColor)
            context.fill(super.bounds(for: .mediaBox))
            context.restoreGState()
            // draw page
            super.draw(with: box, to: context)
        } else {
            // set fill color
            context.saveGState()
            context.setFillColor(documentModel.documentColor.pageBackgroundColor.cgColor)
            context.fill(super.bounds(for: .mediaBox))
            context.restoreGState()
            // draw page
            super.draw(with: box, to: context)
        }
        
    }
    
    
#if canImport(UIKit)
    
    /// Get a thumbnail of the specified size
    ///
    /// - Parameter size: The size of the page thumbnail to be retrieved.
    /// - Parameter box: The `PDF` display box type in which to retrieve the page thumbnail.
    /// - Returns: Returns an `UIImage` instance representing the page thumbnail.
    @available(iOS 15.0, *)
    public override func thumbnail(of size: CGSize, for box: PDFDisplayBox
    ) -> UIImage {
        super.thumbnail(of: size, for: box)
    }
    
#endif
    
#if os(macOS)
    
    
    /// Get a thumbnail of the specified size
    ///
    /// - Parameter size: The size of the page thumbnail to be retrieved.
    /// - Parameter box: The `PDF` display box type in which to retrieve the page thumbnail.
    /// - Returns: Returns an `UIImage` instance representing the page thumbnail.
    @available(macOS 11.0, *)
    public override func thumbnail(of size: CGSize, for box: PDFDisplayBox
    ) -> NSImage {
        super.thumbnail(of: size, for: box)
    }
    
    
#endif
    
}
#endif
