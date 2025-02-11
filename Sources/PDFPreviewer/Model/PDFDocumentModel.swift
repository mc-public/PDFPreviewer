//
//  PDFDocumentModel.swift
//
//
//  Created by 孟超 on 2024/9/16.
//

#if canImport(UIKit)

//FIXME: (2024.10.18) Extract rendering properties such as DocumentColor to PDFDocumentScrollView.

import Foundation
import PDFKit

//MARK: Model Definition

/// Model representing a specific `PDF` document
///
/// This class is essentially a subclass of the `PDFDocument` class provided by the `PDFKit` framework.
@available(iOS 15.0, macOS 11.0, *)
public final class PDFDocumentModel: PDFDocument, PDFDocumentDelegate {
    
    /// The document id of the model.
    internal let id = UUID()
    
    /// `CGPDFDocument` instance created using the data of the current document
    ///
    /// This property is different from the `documentRef` property of the current class, as it creates a brand new `CGPDFDocument` instance.
    public var newDocumentRef: CGPDFDocument? {
        return CGPDFDocument(dataProvider)
    }
    
    /// `CGDataProvider` instance created using the data of the current document.
    public let dataProvider: CGDataProvider
    
    /// Data representation of the current document.
    public let data: Data
    
    /// All available `PDFPage` in the current document
    ///
    /// In this list, all pages will be sorted in ascending order by page number.
    ///
    /// - Complexity: O(`pageCount`)
    public var allPages: [PDFPageModel] {
        var result = [PDFPageModel]()
        for index in 0..<self.pageCount {
            result.append(self.page(at: index) ?? PDFPageModel())
        }
        return result
    }
    
    /// The layout information of all pages included in the current class.
    ///
    /// - Complexity: O(1)
    public let allPageBounds: [PDFPageBounds]
    
    
    /// The page index range about current PDF document.
    var pageIndexRange: Range<Int> {
        (0..<self.pageCount)
    }
    
    /// All overlay views about current PDF document.
    var overlayViews: [PageOverlayView]
    
    /// A `Bool` value indicating whether the range contains no elements.
    public var isEmpty: Bool {
        self.pageIndexRange.isEmpty
    }
    
    /// The display trim level about current document.
    ///
    /// The default value of this property is `.percentage0`.
    @AtomicValue(.NSLock, defaultValue: .percentage0)
    public var trimLevel: TrimLevel {
        didSet {
            self.documentView?.layoutDocumentIfNeeded(goToMainPage: true)
            self.documentView?.updateScale()
        }
    }
    
    /// The page rendering configuration about current document.
    @AtomicValue(.NSLock, defaultValue: DocumentColor.default)
    public private(set) var documentColor: DocumentColor
    
    
    /// Toggle the rendering colors of the page in night mode.
    ///
    /// The page rendering color in night mode is white. After configuring this value, the page rendering color will automatically be changed to black.
    @AtomicValue(.NSLock, defaultValue: true)
    public var invertRenderingColor: Bool {
        didSet { self.documentView?.layoutDocumentIfNeeded() }
    }
    
    @AtomicValue(.NSLock, defaultValue: .light)
    var userInterfaceStyle: UIUserInterfaceStyle
    
    /// The document view of the current document model instance.
    ///
    /// The default value is `nil`. If this document model is added to the document view, this value will be automatically set.
    public private(set) weak var documentView: PDFDocumentScrollView?
    
    @available(*, unavailable)
    override public var delegate: PDFDocumentDelegate? {
        get { super.delegate }
        set { super.delegate = newValue }
    }
    
    /// Get the `PDFPageModel` instance corresponding to the page index
    ///
    /// - Parameter index: The index corresponding to the page instance to be retrieved, with `0` representing the first page.
    ///
    /// - Returns: Returns `nil` if the corresponding page instance is not found.
    public override func page(at index: Int) -> PDFPageModel? {
        if index >= self.pageCount || index < 0 {
            assertionFailure("[\(Self.self)][\(#function)] Page corresponding to index \(index) not found. Please check if the index is valid before using this method. The current total number of pages is \(self.pageCount). This assertion is disabled under release configuration and `nil` is directly returned.")
            return nil
        }
        return super.page(at: index) as? PDFPageModel
    }
    
    /// Get a new `CGPDFPage` instance corresponding to the page index
    ///
    /// - Parameter index: The index corresponding to the page instance to be retrieved, with `0` representing the first page.
    ///
    /// - Returns: Returns `nil` if the corresponding page instance is not found.
    public func newPageRef(at index: Int?) -> CGPDFPage? {
        guard let document = self.newDocumentRef, let index else {
            return nil
        }
        return document.page(at: index + 1)
    }
    
    /// Get a new `PDFPage` instance corresponding to the page index
    ///
    /// - Parameter index: The index corresponding to the page instance to be retrieved, with `0` representing the first page.
    ///
    /// - Returns: Returns a `PDFPage` instance. This instance cannot be forcibly unwrapped as `PDFPageModel`. Returns `nil` if the corresponding page instance is not found.
    public func newPage(at index: Int) -> PDFPage? {
        guard let document = PDFDocument(data: data) else {
            return nil
        }
        if index >= document.pageCount {
            assertionFailure("[\(Self.self)][\(#function)] Page corresponding to index \(index) not found. Please check if the index is valid before using this method. The current total number of pages is \(self.pageCount). This assertion is disabled under release configuration and `nil` is directly returned.")
            return nil
        }
        return document.page(at: index) ?? .init()
    }
    
    /// Get the index corresponding to the `PDFPageModel` instance in the current document
    ///
    /// - Parameter page: The `PDFPageModel` for which to find the index, with `0` representing the first page. The page represented by this instance must be in the current document.
    /// If this method does not find the corresponding index of the given page in the current document, an error will be thrown and the constant `NSNotFound` will be returned.
    public func index(for page: PDFPageModel) -> Int {
        super.index(for: page)
    }
    
    /// Initialize a `PDFDocumentModel` instance with the given data
    ///
    /// Returns an instance if the data is valid. Otherwise, returns `nil`.
    ///
    /// - Parameter data: Data representing the `PDF` file.
    @MainActor
    public init?(_ data: Data) {
        self.data = data
        guard let provider = CGDataProvider(data: data as CFData) else {
            return nil
        }
        self.dataProvider = provider
        guard let pdfDocument = PDFDocument(data: data) else { return nil }
        self.allPageBounds = (0..<pdfDocument.pageCount).map {
            .init(document: pdfDocument, at: $0)
        }
        self.overlayViews = (0..<pdfDocument.pageCount).map { _ in PageOverlayView() }
        super.init(data: data)
        self.commonInit()
    }
    
    /// Initialize a `PDFDocumentModel` instance with the given `URL`
    ///
    /// Returns an instance if the file corresponding to the `URL` is accessible and is a valid `PDF` file. Otherwise, returns `nil`.
    ///
    /// - Parameter url: The `URL` representing the `PDF` file.
    @MainActor
    public init?(_ url: URL) {
        if let data = try? Data(contentsOf: url), let provider = CGDataProvider(data: data as CFData) {
            self.data = data
            self.dataProvider = provider
        } else { return nil }
        guard let pdfDocument = PDFDocument(data: data) else { return nil }
        self.allPageBounds = (0..<pdfDocument.pageCount).map {
            .init(document: pdfDocument, at: $0)
        }
        self.overlayViews = (0..<pdfDocument.pageCount).map { _ in PageOverlayView() }
        super.init(url: url)
        self.commonInit()
    }
    
    /// Returns the type of page model used by the current class
    ///
    /// This method always returns `PDFPageModel`.
    public func classForPage() -> AnyClass {
        PDFPageModel.self
    }
    
    /// Update the display color of the current document.
    ///
    /// - Parameter color: Desired new update.
    @MainActor
    public func updateDocumentColor(_ color: DocumentColor) {
        self.documentColor = color
        self.documentView?.backgroundColor = color.backgroundColor
        (self.documentView as PDFView?)?.pageShadowsEnabled = color.pageBorder.showingPageShadow
        self.documentView?.layoutDocumentIfNeeded(goToMainPage: false)
        self.overlayViews.forEach { view in
            view.updateStyle(color)
        }
    }
    
    @MainActor
    func addDocumentView(_ view: PDFDocumentScrollView) {
        (view as PDFView).pageOverlayViewProvider = self
        self.documentView = view
        self.updateDocumentColor(self.documentColor)
        self.userInterfaceStyle = view.traitCollection.userInterfaceStyle
    }
    
    private func commonInit() {
        super.delegate = self
    }
    
    
}

//MARK: - PDFPageOverlayViewProvider

extension PDFDocumentModel: PDFPageOverlayViewProvider {
    public func pdfView(_ view: PDFView, overlayViewFor page: PDFPage) -> UIView? {
        guard let page = page as? PDFPageModel else { return nil }
        return self.overlayViews[self.index(for: page)]
    }
   
}

//MARK: - Unavailable Methods

extension PDFDocumentModel {
    @available(*, unavailable)
    override public func index(for page: PDFPage) -> Int {
        super.index(for: page)
    }
    @available(*, unavailable)
    override public func removePage(at index: Int) {
        super.removePage(at: index)
    }
    @available(*, unavailable)
    override public func insert(_ page: PDFPage, at index: Int) {
        super.insert(page, at: index)
    }
    @available(*, unavailable)
    public override func exchangePage(at indexA: Int, withPageAt indexB: Int) {
        super.exchangePage(at: indexA, withPageAt: indexB)
    }
}

#endif
