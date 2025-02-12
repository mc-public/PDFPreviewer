//
//  PDFPreviewerModel+ScrollViewDelegate.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/10/16.
//

#if os(iOS)

import UIKit

//MARK: - PDFDocumentScrollViewDelegate

extension PDFPreviewerModel: PDFDocumentScrollViewDelegate {
    public final func documentViewDidZoom(_ documentView: PDFDocumentScrollView, zoomScale: CGFloat, isFinished: Bool) {
        self.updateView()
    }
    
    public final func documenViewDidChangeVisiblePages(_ documentView: PDFDocumentScrollView) {
        self.updateView()
    }
    
    public final func documenViewDidChangeMainPage(_ documentView: PDFDocumentScrollView, to pageIndex: Int) {
        self.updateView()
    }
}

#endif
