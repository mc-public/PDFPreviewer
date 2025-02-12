//
//  PDFPageLayoutInfo.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/9/17.
//

import CoreGraphics
#if canImport(PDFKit) && canImport(UIKit)
import PDFKit

/// A structure representing various margins and rotation angle of a specific PDF page.
public struct PDFPageBounds: Sendable {
    /// Enumerate the *clockwise* rotation angles of PDF pages.
    public enum Rotation: Sendable {
        case clockwise0
        case clockwise90
        case clockwise180
        case clockwise270
        /// The angle of the rotation.
        public var angle: Int {
            switch self {
                case .clockwise0: 0
                case .clockwise90: 90
                case .clockwise180: 180
                case .clockwise270: 270
            }
        }
    }
    
    private var mediaBox: CGRect
    private var cropBox: CGRect
    private var bleedBox: CGRect
    private var trimBox: CGRect
    private var artBox: CGRect
    
    /// The rotation angle of the page.
    public var rotation: Rotation
    
    /// Construct current layout information using the specified page index.
    init(document: PDFDocument, at pageIndex: Int) {
        let pageModel = document.page(at: pageIndex) ?? .init()
        self.mediaBox = pageModel.bounds(for: .mediaBox)
        self.cropBox = pageModel.bounds(for: .cropBox)
        self.bleedBox = pageModel.bounds(for: .bleedBox)
        self.trimBox = pageModel.bounds(for: .trimBox)
        self.artBox = pageModel.bounds(for: .artBox)
        self.rotation = if (pageModel.rotation % 360) == 0 {
            .clockwise0
        } else if (pageModel.rotation % 360) == 90 {
            .clockwise180
        } else if (pageModel.rotation % 360) == 180 {
            .clockwise180
        } else {
            .clockwise270
        }
    }
    /// Get the bounding rectangle of the current page.
    ///
    /// - Parameter box: The type of the PDFBox bounds that you want to obtain.
    public func bounds(for box: PDFDisplayBox) -> CGRect {
        switch box {
            case .mediaBox: mediaBox
            case .cropBox: cropBox
            case .bleedBox: bleedBox
            case .trimBox: trimBox
            case .artBox: artBox
            @unknown default: mediaBox
        }
    }
    
    /// Get the rotated bound size of the current page.
    ///
    /// - Parameter box: The type of the PDFBox bounds that you want to obtain.
    public func rotatedSize(for box: PDFDisplayBox) -> CGSize {
        let size = self.bounds(for: box).size
        return (self.rotation == .clockwise90 || self.rotation == .clockwise270) ? .init(width: size.height, height: size.width) : size
    }
}
#endif
