//
//  PDFDocumentModel+ColorTheme.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/10/15.
//

#if os(iOS)
import PDFKit

extension UIColor {
    fileprivate static let dynamicBlack = UIColor { collection in
        collection.userInterfaceStyle == .light ? .black : .white
    }
}

extension PDFDocumentModel {
    
    /// Struct representing the page border style in the current document.
    public struct PageBorder: Sendable, Equatable, Hashable {
        /// Show page shadow for the current page.
        ///
        /// When this value is `true`, only the shadow will be displayed, and the border will not be shown.
        public let showingPageShadow: Bool
        /// The border color of the page view.
        public let borderColor: UIColor
        /// The border width of the page view.
        public let borderWidth: CGFloat
        
        /// Create a border that only shows shadows.
        public init() {
            self.showingPageShadow = true
            self.borderColor = .clear
            self.borderWidth = 0.0
        }
        
        /// Create a line-style border without displaying shadows.
        public init(borderColor: UIColor, borderWidth: CGFloat) {
            self.showingPageShadow = false
            self.borderColor = borderColor
            self.borderWidth = borderWidth
        }
        
        /// A border that only shows shadows.
        public static let `default` = Self()
        /// A border that automatically switch between black or white based on the current environment.
        public static let dynamicBlack = Self(borderColor: .dynamicBlack, borderWidth: 1)
        /// All built-in PDF borders.
        static var allBuildBorders: [Self] { [.default, .dynamicBlack] }

    }
    
    /// Struct for representing colors displayed on a page.
    public struct DocumentColor: Sendable, Hashable {
        /// The background color of the page view.
        public var pageBackgroundColor: UIColor
        /// The page border of the document view.
        public var pageBorder: PageBorder
        /// The background color of the document view.
        public var backgroundColor: UIColor
        
        
        /// Create an instance of a struct representing document color.
        ///
        /// - Parameter pageBackgroundColor: Background color **used in light mode**.
        /// - Parameter pageBorder: The page border of the document.
        /// - Parameter backgroundColor: Background color used in light mode. The color in dark mode is permanently fixed.
        public init(pageBackgroundColor: UIColor = .white, pageBorder: PageBorder = .default, backgroundColor: UIColor) {
            self.pageBackgroundColor = pageBackgroundColor
            self.backgroundColor = UIColor { collection in
                collection.userInterfaceStyle == .light ? backgroundColor : Self.darkBackground
            }
            self.pageBorder = pageBorder
        }
        
        private static let darkPage = UIColor.black
        private static let darkBackground = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        /// All built-in themes.
        public static var allBuildThemes: [DocumentColor] {
            [.default, .lightDaytime, .lightEyeProtection, .lightParchment]
        }
        
        /// The default color about current view.
        public static let `default` = DocumentColor(backgroundColor: UIColor(red: 0.933, green: 0.933, blue: 0.933, alpha: 1.0))
        /// The day-time light color about the document.
        public static let lightDaytime = DocumentColor(pageBackgroundColor: UIColor(red: 0.976, green: 0.976, blue: 0.976, alpha: 1.0), backgroundColor: .white)
        /// The parchment light color about the document.
        public static let lightParchment = DocumentColor(pageBackgroundColor: UIColor(red: 0.871, green: 0.843, blue: 0.745, alpha: 1.0), backgroundColor: UIColor(red: 0.894, green: 0.867, blue: 0.765, alpha: 1.0))
        /// The eye protection green-color the document.
        public static let lightEyeProtection = DocumentColor(pageBackgroundColor: UIColor(red: 0.804, green: 0.867, blue: 0.761, alpha: 1.0), backgroundColor: UIColor(red: 0.824, green: 0.890, blue: 0.780, alpha: 1.0))
    }
}

extension PDFDocumentModel {
    
    /// The page overlay view about current PDF document.
    final class PageOverlayView: UIView {
        typealias DocumentColor = PDFDocumentModel.DocumentColor
        private var documentColor: DocumentColor?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.commonInit()
        }
        
        private func commonInit() {
            self.isOpaque = false
            self.backgroundColor = .clear
            if #available(iOS 17.0, *) {
                self.registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(self.updateUserStyle))
            }
        }
        
        func updateStyle(_ color: DocumentColor) {
            self.documentColor = color
            // set border
            self.layer.borderWidth = color.pageBorder.borderWidth
            self.layer.borderColor = color.pageBorder.borderColor.cgColor
        }
        
        @objc private func updateUserStyle() {
            if let documentColor {
                self.updateStyle(documentColor)
            }
        }
        
        @available(iOS, deprecated: 17.0)
        public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            self.updateUserStyle()
        }
    }
}
#endif
