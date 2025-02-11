//
//  PDFPageMargin.swift
//
//
//  Created by 孟超 on 2024/9/16.
//

import Foundation

#if os(iOS)
import UIKit

/// A struct representing page margins in the current view
///
/// Since the pages are centered, we cannot specify the left and right margins separately for each page, but assume that the left margin of each page is equal to the right margin.
public struct PDFPageMargin: Sendable {
    
    static let `default` = PDFPageMargin(top: 5.0, bottom: 5.0)
    
    /// Top margin of the page.
    public let top: CGFloat
    /// Bottom margin of the page.
    public let bottom: CGFloat
    
    /// Construct a struct representing page margins using the specified margin information.
    public init(top: CGFloat, bottom: CGFloat) {
        assert(top >= 0 && bottom >= 0, "[\(Self.self)][\(#function)] The margin parameters passed in must be non-negative, otherwise it will cause view abnormalities. This check will be disabled in release mode.")
        self.top = top
        self.bottom = bottom
    }
    
    var verticalInsets: CGFloat {
        self.top + self.bottom
    }
    
    var insets: UIEdgeInsets {
        UIEdgeInsets(top: self.top, left: 0.0, bottom: self.bottom, right: 0.0)
    }
}

#endif
