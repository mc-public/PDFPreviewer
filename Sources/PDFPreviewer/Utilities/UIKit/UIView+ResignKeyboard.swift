//
//  UIView+ResignKeyboard.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/10/7.
//

#if os(iOS)
import UIKit
import PDFKit

extension UIView {
    @AtomicValue(.NSLock, defaultValue: false)
    private static var CanResignKeyboard: Bool
    
    /// Returns a Boolean value indicating whether the responder is willing to relinquish first-responder status.
    ///
    /// `true` if the responder can resign first-responder status; otherwise, `false`.
    ///
    /// This method returns `true` by default. You can override this method in your custom responders and return a different value if needed. For example, a text field containing invalid content might want to return false to ensure that the user corrects that content first.
    override open var canResignFirstResponder: Bool {
        if (self.superview?.superview as? PDFDocumentScrollView)?.internalUsingSwiftUI == true {
            if !Self.CanResignKeyboard {
                return true
            }
        } /* This is a hack to solve the issue of `PDFDocumentView` inside PDFKit framework refusing to resignFirstResponder. */
        if Self.CanResignKeyboard {
            return super.canResignFirstResponder
        }
        return false
    }
    
    /// Notifies this object that it has been asked to relinquish its status as first responder in its window.
    override open func resignFirstResponder() -> Bool {
        if (self.superview?.superview as? PDFDocumentScrollView)?.internalUsingSwiftUI == true {
            if !Self.CanResignKeyboard {
                return true
            }
        } /* This is a hack to solve the issue of `PDFDocumentView` inside PDFKit framework refusing to resignFirstResponder. */
        if Self.CanResignKeyboard {
            return super.canResignFirstResponder
        }
        return false
    }
    
    /// Prevent all `UIView`s to resign first responder.
    static func PreventResignFirstResponder() {
        Self.CanResignKeyboard = false
    }
    
    /// Allow all `UIView`s to resign first responder.
    @MainActor
    static func AllowResignFirstResponder(async: Bool = false, onCompletion: @MainActor @escaping () -> ()) {
        if async {
            DispatchQueue.main.async {
                Self.CanResignKeyboard = true
                onCompletion()
            }
        } else {
            Self.CanResignKeyboard = false
            onCompletion()
        }
    }
}




#endif
