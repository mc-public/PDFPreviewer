//
//  PDFPreviewerModel.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/10/8.
//

#if canImport(SwiftUI) && canImport(UIKit)

import SwiftUI
import PDFKit


//MARK: - Utilities

/// Protocol followed by the data source for loading PDF documents.
///
/// - Warning: Only support `Data` and `URL` types, do not conform custom types to their protocols, otherwise it will cause runtime errors.
public protocol PDFDocumentResource {}
extension Data: PDFDocumentResource {}
extension URL: PDFDocumentResource {}


//MARK: - PDFPreviewerModel

/// View model used to control the `PDFPreviewer`.
@MainActor
open class PDFPreviewerModel: ObservableObject {
    
    let view: PDFDocumentScrollView
    let constraintView: PDFDocumentConstraintView
    
    /// The PDF document displayed in the current view.
    var document: PDFDocumentModel?
    
    /// The navigation aboout current view.
    ///
    /// This property controls the page position and zoom level of the current PDF view.
    public final private(set) var navigation: Navigation?
    
    /// The interaction delegate about current view.
    ///
    /// The default value is `nil`. Setting it will change the default interaction behavior of the view, such as context menus and double-tap behavior.
    public final var interactionDelegate: (any InteractionDelegate)? {
        didSet { self.constraintView.updateTapGesture() }
    }
    /// The display trim level about current previewer.
    ///
    /// The default value of this property is `.percentage0`.
    @Published public final var trimLevel: PDFDocumentModel.TrimLevel = .percentage0 {
        didSet { self.document?.trimLevel = self.trimLevel }
    }
    /// Toggle the rendering colors of the page in night mode.
    ///
    /// Default value is `true`. The system-default page rendering color in night mode is `white`. After configuring this value to `true`, the page rendering color will automatically be changed to black.
    @Published public final var invertRenderingColor = true {
        didSet { self.document?.invertRenderingColor = self.invertRenderingColor }
    }
    
    /// The display color of the current previewer.
    @Published public final var themeColor: PDFDocumentModel.DocumentColor = .default {
        didSet { self.document?.updateDocumentColor(self.themeColor) }
    }
    /// Lock the current view’s zoom state to automatic zoom state.
    ///
    /// The default value is `false`. When this value is set to true, the zoom level of the current view will be locked to automatic scaling.
    @Published public final var lockingAutoScale: Bool = false {
        didSet { self.view.lockingAutoScale = lockingAutoScale }
    }
    
    /// Return the scaling ratio of the entire document.
    ///
    /// When the document exactly fills the width of the entire view, this value is `1.00`.
    public final var documentScale: CGFloat {
        get { self.view.documentScale }
        set {
            self.view.documentScale = newValue
            self.updateView()
        }
    }
    
    /// Create a `PDFPreviewer` view model.
    public init() {
        self.view = PDFDocumentScrollView(usingSwiftUI: true)
        self.constraintView = .init(documentView: self.view)
        self.view.viewDelegate = self
        self.constraintView.addPreviewerModel(self)
    }
    
    /// Load the PDF document from the specified data source.
    ///
    /// - Parameter source: PDF file to be loaded. Type can be `URL` or `Data`.
    /// - Parameter restoreViewportState: Indicates whether to move the viewport back to its original position after updating the document. The default value is `false`.
    /// - Parameter resignKeyboard: Indicates whether to dismiss the keyboard when updating the document. Default value is `true`.
    public final func loadDocument<T>(from source: T, restoreViewportState: Bool = false, resignKeyboard: Bool = false) async where T: PDFDocumentResource {
        if let source = source as? URL {
            self.document = .init(source)
        } else if let source = source as? Data {
            self.document = .init(source)
        } else { fatalError("[\(Self.self)][\(#function)] Does not support custom PDF document data sources.") }
        if let document {
            document.trimLevel = self.trimLevel
            document.invertRenderingColor = self.invertRenderingColor
            document.updateDocumentColor(self.themeColor)
            await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
                self.view.updateDocumentModel(document, restoreViewportState: restoreViewportState, resignKeyboard: resignKeyboard) {
                    self.navigation = Navigation(self, document: document)
                    cont.resume()
                }
            }
        }
    }
    
    func updateView() {
        self.objectWillChange.send()
        self.navigation?.objectWillChange.send()
    }
}

#endif
