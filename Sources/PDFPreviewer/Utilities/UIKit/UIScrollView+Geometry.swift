//
//  UIScrollView+Geometry.swift
//
//
//  Created by 孟超 on 2024/9/16.
//

#if os(iOS)

import UIKit

extension UIScrollView {
    
    /// The visible rectangle of current scroll view.
    ///
    /// This value is related to zooming.
    var visibleRect: CGRect {
        CGRect(origin: self.contentOffset, size: self.visibleSize)
    }
    
    /// The content rectangle of current scroll view.
    ///
    /// This value is independent of zooming.
    var contentRect: CGRect {
        CGRect(origin: CGPoint.zero, size: self.contentSize)
    }
    
    /// The rescaled rectangle of current scroll view.
    ///
    /// This value is not related to zooming.
    var rescaledVisibleRect: CGRect {
        self.visibleRect.rescale(self.zoomScale)
    }
}

#endif
