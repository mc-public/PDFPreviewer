//
//  PDFDocumentScrollView+ScrollDelegate.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/10/8.
//

#if canImport(UIKit)
import UIKit

@available(iOS 16.0, *)
extension PDFDocumentScrollView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.innerScrollViewDelegate?.scrollViewDidScroll?(scrollView)
        self.checkPreviousCurrentPageChange()
        self.hackTileLayerColor()
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.innerScrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.innerScrollViewDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.innerScrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        self.innerScrollViewDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        self.innerScrollViewDelegate?.scrollViewDidScrollToTop?(scrollView)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.innerScrollViewDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.innerScrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        self.innerScrollViewDelegate?.viewForZooming?(in: scrollView)
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.innerScrollViewDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
        self.hackTileLayerColor()
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.innerScrollViewDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
        self.hackTileLayerColor()
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.viewDelegate?.documentViewDidZoom?(self, zoomScale: super.scaleFactor, isFinished: false)
        if super.scaleFactor == super.scaleFactorForSizeToFit {
            super.autoScales = true
        }
        self.innerScrollViewDelegate?.scrollViewDidZoom?(scrollView)
        self.hackTileLayerColor()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.innerScrollViewDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        self.innerScrollViewDelegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)

    }
}

#endif
