//
//  PDFPreviewerModel+Navigation.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/10/16.
//

#if os(iOS)

import SwiftUI

//MARK: - Navigation

extension PDFPreviewerModel {
    
    /// Class used for controlling page navigation in `PDFPreviewer`.
    ///
    /// Access relevant information about the page in the current view and perform page navigation operations through this class.
    @MainActor
    public final class Navigation: ObservableObject {
        private let view: PDFDocumentScrollView
        /// The PDF document displayed in the current view.
        private var document: PDFDocumentModel
        /// The page index range about current PDF document.
        public var pageIndexRange: Range<Int> {
            self.document.pageIndexRange
        }
        /// The main page index about current view.
        public var mainPageIndex: Int {
            if let mainPage = self.view.mainPage {
                return self.document.index(for: mainPage)
            }
            return 0
        }
        /// Index of all visible pages in the current view.
        public var visiblePageIndices: [Int] {
            self.view.allVisiblePages.map { self.document.index(for: $0) }
        }
        
        init(_ model: PDFPreviewerModel, document: PDFDocumentModel) {
            self.view = model.view
            self.document = document
        }
        
        /// Go to the page corresponding to the specified index.
        ///
        /// - Parameter index: The index of the page to navigate to. The value must not exceed the bounds, otherwise a runtime error will be thrown.
        /// - Parameter rect: The rectangle on the page you want to navigate to. The rectangle is specified in page-space coordinates. Page space is a `72` dpi coordinate system with the origin at the lower-left corner of the current page.
        public func go(to index: Int, rect: CGRect? = nil) {
            if let page = self.document.page(at: index) {
                if let rect {
                    self.view.go(to: rect, on: page)
                } else {
                    self.view.go(to: page)
                }
            }
        }
        
        /// Trigger the highlighting of several rectangles on the specified page.
        ///
        /// When triggered, the page will navigate to the rectangular area highlighted based on the minimum scrolling distance principle.
        ///
        /// - Parameter pageIndex: This parameter represents the index of the page. Index starts from 0.
        /// - Parameter rects: A list of rectangles to be highlighted. These rectangles must be in the page view coordinate system of the PDF, with the origin at the **bottom left corner**.
        /// - Parameter duration: Duration of highlighted. Unit is seconds.
        /// - Parameter color: The color used for highlighting. Default to yellow.
        public func triggerHighlight(pageIndex: Int, rects: [CGRect], duration: TimeInterval = 0.3, color: Color = .yellow) {
            let color = UIColor(color)
            self.view.triggerHighlight(pageIndex: pageIndex, rects: rects, duration: duration, color: color)
        }
    }
}

#endif

