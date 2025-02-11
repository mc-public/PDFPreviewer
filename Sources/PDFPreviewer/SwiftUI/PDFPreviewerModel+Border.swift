//
//  PDFPreviewerModel+Border.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/10/16.
//

#if canImport(UIKit)
import SwiftUI

extension PDFPreviewerModel {
    /// Struct for customizing page border style.
    public struct PageBorder: Sendable {
        var showingPageShadow: Bool
        var borderColor: Color
        var borderWidth: CGFloat
        
        /// Indicate whether the current style is a shadow style.
        public var isShadowBorder: Bool {
            self.showingPageShadow
        }
        
        /// Create a border with a line segment style.
        ///
        /// - Parameter color: The color of the page border.
        /// - Parameter width: The width of the page border. The default value is `0.5`.
        public init(color: Color, width: CGFloat = 1.0) {
            self.showingPageShadow = false
            self.borderColor = color
            self.borderWidth = width
        }
        /// Create a shadow-type page border.
        ///
        /// The style of the shadow does not support customization.
        public init() {
            self.showingPageShadow = true
            self.borderColor = .clear
            self.borderWidth = 0.0
        }
    }
}


#endif
