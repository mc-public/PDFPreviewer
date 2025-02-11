//
//  PDFDocumentModel+TrimLevel.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/10/7.
//

import CoreGraphics

#if canImport(UIKit)
import UIKit

extension PDFDocumentModel {
    /// Center trim level suitable for the current document.
    public enum TrimLevel: CGFloat, Sendable, CaseIterable {
        /// The cropped document is the same as the original document.
        case percentage0 = 0.0
        /// Crop 5% of the page width and height.
        case percentage5 = 2.5
        /// Crop 10% of the page width and height.
        case percentage10 = 5.0
        /// Crop 15% of the page width and height.
        case percentage15 = 7.5
        /// Crop 20% of the page width and height.
        case percentage20 = 10.0
        /// Crop 25% of the page width and height.
        case percentage25 = 12.5
    }
}

#endif
