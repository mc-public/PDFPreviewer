//
//  PDFPreviewer.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/10/15.
//

#if canImport(SwiftUI) && canImport(UIKit)

import SwiftUI

/// SwiftUI view for displaying PDF documents.
///
/// Use this view to display PDF documents. You can control the zoom, center zoom, auto zoom, etc. of the PDF document, as well as control the theme of the PDF document.
public struct PDFPreviewer: View {
    @ObservedObject var model: PDFPreviewerModel
    /// Create a PDF previewer using the specified `PDFPreviewerModel` view model instance.
    ///
    /// - Parameter model: The view model specified when creating the PDF view. The current view will hold a **weak reference** to this instance.
    public init(model: PDFPreviewerModel) {
        self._model = .init(initialValue: model)
    }
    
    public var body: some View {
        PDFPreviewerWrapper(model: model)
    }
}


struct PDFPreviewerWrapper: UIViewRepresentable {
    
    @ObservedObject var model: PDFPreviewerModel
    
    func makeUIView(context: Context) -> PDFDocumentConstraintView {
        self.model.constraintView
    }
    
    func updateUIView(_ uiView: PDFDocumentConstraintView, context: Context) {}
    
    typealias UIViewType = PDFDocumentConstraintView
}

#endif
