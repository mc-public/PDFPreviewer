//
//  PDFDocumentScrollView.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/10/7.
//

#if os(iOS)
import PDFKit
/// View for displaying PDF document pages.
///
/// This view is essentially a subclass of `PDFView`.
@available(iOS 16.0, *)
open class PDFDocumentScrollView: PDFView {
    
    /// Class representing touch operations performed by the user on a PDF page.
    public class PDFDocumentTapPosition: NSObject {
        /// Page tapped by the user.
        public let page: PDFPageModel
        /// Touch position in the PDF standard coordinate system.
        ///
        /// The origin of the coordinate system is at the bottom-left corner of the page, with dimensions matching the `mediaBox` of the page.
        public let point: CGPoint
        
        init(page: PDFPageModel, point: CGPoint) {
            self.page = page
            self.point = point
            super.init()
        }
    }
    
    /// Indicate whether the current view is being displayed in SwiftUI.
    var internalUsingSwiftUI: Bool = false
    
    /// Menu items on the left side of the PDF selection menu.
    ///
    /// After setting this value, the next displayed selection menu will show the menu items in this list in sequence on the left side.
    public var leadingSelectionMenuItems: [PDFDocumentMenuItem] = []
    /// Menu items on the right side of the PDF selection menu.
    ///
    /// After setting this value, the next displayed selection menu will show the menu items in this list in sequence on the right side.
    public var trailingSelectionMenuItems: [PDFDocumentMenuItem] = []
    
    /// The delegate for the `PDFDocumentScrollView` object.
    public var viewDelegate: (any PDFDocumentScrollViewDelegate)?
    
    /// The document model about current document view.
    ///
    /// Setting this value to `nil` will clear the display of the view.
    public private(set) var documentModel: PDFDocumentModel?
    
    /// Returns the current page.
    ///
    /// When there are two pages in the view in a two-up mode, “current page” is the left page. For continuous modes, returns the page crossing a horizontal line halfway between the view’s top and bottom bounds.
    public final var mainPage: PDFPageModel? {
        get {
            self.page(for: self.bounds.center, nearest: true) as? PDFPageModel
        }
        set {
            if let newValue { self.go(to: newValue) }
        }
    }
    
    /// Returns an array of `PDFPageModel` objects that represent the currently visible pages.
    public final var allVisiblePages: [PDFPageModel] {
        (super.visiblePages as? [PDFPageModel]) ?? []
    }
    
    /// The scroll view about current PDF document view.
    ///
    /// The innermost view is the one displaying the visible document pages. The scroll view is the super view of this view.
    public final var scrollView: UIScrollView? {
        self.documentView?.superview as? UIScrollView
    }
    
    /// The double tap gesture recognizer attached to the current view.
    private var doubleTapGesture: UITapGestureRecognizer?
    
    /// Action performed when double-tap the current view.
    ///
    /// The default value is `nil`. This value being `nil` means that the default double-tap zoom gesture is used.
    public var doubleTapAction: ((PDFDocumentTapPosition) -> ())? = nil {
        didSet {
            if let doubleTapGesture {
                self.removeGestureRecognizer(doubleTapGesture)
            }
            if self.doubleTapAction != nil {
                let gesture = UITapGestureRecognizer()
                gesture.numberOfTapsRequired = 2
                gesture.addTarget(self, action: #selector(self.didDoubleTap(_:)))
                self.doubleTapGesture = gesture
                self.addGestureRecognizer(gesture)
            } else {
                self.doubleTapGesture = nil
            }
        }
    }
    
    var preventDefaultMenu: Bool = true
    
    /// Lock the current view's zoom state to automatic zoom state.
    ///
    /// The default value is `false`, which allows a scaling factor between `Self.MinDocumentScaleFactor` and `Self.MinDocumentScaleFactor` when set to false. When this value is set to `true`, the zoom level of the current view will be locked to automatic scaling.
    public var lockingAutoScale: Bool = false {
        didSet { self.updateScale() }
    }
    
    /// The minimum scale ratio supported by the current view.
    public static let MinDocumentScaleFactor: CGFloat = 0.5
    /// The maximum scale ratio supported by the current view.
    public static let MaxDocumentScaleFactor: CGFloat = 3.0
    
    /// Return the scaling ratio of the entire document.
    ///
    /// When the document exactly fills the width of the entire view, this value is `1.00`. This value must be between `Self.MinDocumentScaleFactor` and `Self.MaxDocumentScaleFactor`.
    public final var documentScale: CGFloat {
        get {
            if super.scaleFactorForSizeToFit.isAlmostZero() {
                return 1.00
            }
            return super.scaleFactor / super.scaleFactorForSizeToFit
        }
        set {
            if super.scaleFactorForSizeToFit.isAlmostZero() { return }
            let value = min(max(Self.MinDocumentScaleFactor, newValue), Self.MaxDocumentScaleFactor)
            super.scaleFactor = super.scaleFactorForSizeToFit * value
        }
    }
    
    /// The scroll view delegate of the inner scroll view.
    var innerScrollViewDelegate: UIScrollViewDelegate? {
        self.documentView?.superview as? UIScrollViewDelegate
    }
    /// Last saved main page.
    var previousMainPage: PDFPageModel?
    
    
    
    /// Creates a view with the specified frame rectangle.
    ///
    /// - Parameter frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. This method uses the frame rectangle to set the center and bounds properties accordingly.
    /// - Parameter usingSwiftUI: Indicate whether the current view is being displayed in SwiftUI. The default value of this parameter is `false`. When this value is set to `true`, all original long-press finger gestures and selection of `PDFView` are disabled.
    public init(frame: CGRect = .zero, usingSwiftUI: Bool = false) {
        self.internalUsingSwiftUI = usingSwiftUI
        super.init(frame: frame)
        commonInit()
    }
    
    /// Creates a view from data in an unarchiver.
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    @objc private func didDoubleTap(_ gesture: UITapGestureRecognizer) {
        let viewPoint = gesture.location(in: self)
        guard let page = self.page(for: viewPoint, nearest: false) as? PDFPageModel else { return }
        let pagePoint = self.convert(viewPoint, to: page)
        let tapAction = PDFDocumentTapPosition(page: page, point: pagePoint)
        self.doubleTapAction?(tapAction)
    }
    
    /// Set the document displayed in the current view.
    ///
    /// - Parameter model: Document to be updated.
    /// - Parameter restoreViewportState: Indicates whether to move the viewport back to its original position after updating the document. The default value is `false`.
    /// - Parameter resignKeyboard: Indicates whether to dismiss the keyboard when updating the document. Default value is `true`.
    /// - Parameter onCompletion: Closure to be executed after document update is completed.
    public func updateDocumentModel(_ model: PDFDocumentModel?, restoreViewportState: Bool = false, resignKeyboard: Bool = false, onCompletion: @MainActor @escaping () -> ()) {
        // Prepare View State Transition
        var originPageIndex: Int?
        var originPageRect: CGRect?
        var originZoomScale: CGFloat?
        if restoreViewportState, let documentModel, model != nil, let page = self.page(for: .zero, nearest: true) as? PDFPageModel {
            originPageIndex = documentModel.index(for: page)
            originPageRect = self.convert(self.bounds, to: page)
            originZoomScale = super.scaleFactor
        }
        // Update Document
        if resignKeyboard { UIView.PreventResignFirstResponder() }
        self.documentModel = model
        model?.addDocumentView(self)
        super.document = model
        if let scrollView {
            scrollView.delegate = self
        }
        // Execute View State Transition
        if restoreViewportState, let originPageRect, let originPageIndex, let originZoomScale, let model, model.pageCount >= 1 {
            let newIndex = min(originPageIndex, model.pageCount - 1)
            if let targetPage = model.page(at: newIndex) {
                if !self.lockingAutoScale {
                    super.scaleFactor = originZoomScale
                }
                self.go(to: originPageRect, on: targetPage)
            }
        }
        self.updateScale()
        if resignKeyboard {
            UIView.AllowResignFirstResponder(async: true) {
                onCompletion()
            }
        } else {
            onCompletion()
        }
    }
    
    nonisolated func updateScale() {
        let action = { @MainActor in
            if self.lockingAutoScale {
                super.minScaleFactor = super.scaleFactorForSizeToFit
                super.maxScaleFactor = super.scaleFactorForSizeToFit
                super.autoScales = true
            } else {
                super.minScaleFactor = Self.MinDocumentScaleFactor * super.scaleFactorForSizeToFit
                super.maxScaleFactor = Self.MaxDocumentScaleFactor * super.scaleFactorForSizeToFit
            }
        }
        if Thread.isMainThread {
            MainActor.assumeIsolated(action)
        } else {
            Task { @MainActor in
                action()
            }
        }
    }
    
    @objc
    private func updateDocumentUserStyle() {
        self.documentModel?.userInterfaceStyle = self.traitCollection.userInterfaceStyle
        self.setNeedsDisplay()
    }
    
    private func commonInit() {
        // Regular properties
        super.pageShadowsEnabled = true
        //self.pageBreakMargins = UIEdgeInsets(top: 1.0, left: 0.0, bottom: 0.0, right: 1.0)
        // regist color change
        if #available(iOS 17.0, *) {
            self.registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(self.updateDocumentUserStyle))
        }
        // scale change
        NotificationCenter.default.addObserver(forName: .PDFViewScaleChanged, object: nil, queue: .main) { [weak self] notification in
            if let self, let object = notification.object as? PDFDocumentScrollView, object === self {
                MainActor.assumeIsolated {
                    object.viewDelegate?.documentViewDidZoom?(self, zoomScale: (self as PDFView).scaleFactor, isFinished: true)
                }
            }
        }
        // pages change
        NotificationCenter.default.addObserver(forName: .PDFViewVisiblePagesChanged, object: nil, queue: .main) { [weak self] notification in
            if let self, let object = notification.object as? PDFDocumentScrollView, object === self {
                MainActor.assumeIsolated {
                    object.viewDelegate?.documenViewDidChangeVisiblePages?(self)
                    self.checkPreviousCurrentPageChange()
                }
            }
        }
    }
    
    /// Performs layout of the inner views and maintain the displayed page.
    nonisolated func layoutDocumentIfNeeded(goToMainPage: Bool = false) {
        let layoutBody = { @MainActor in
            let mainPage = self.mainPage
            super.layoutDocumentView()
            self.setNeedsDisplay()
            if let mainPage, goToMainPage {
                self.go(to: mainPage)
            }
        }
        if Thread.isMainThread {
            MainActor.assumeIsolated {
                layoutBody()
            }
        } else {
            Task { @MainActor in
                layoutBody()
            }
        }
    }
    
    func checkPreviousCurrentPageChange() {
        if let page = self.mainPage, let model = self.documentModel, (self.previousMainPage == nil) || (self.previousMainPage !== page)  {
            self.viewDelegate?.documenViewDidChangeMainPage?(self, to: model.index(for: page))
            self.previousMainPage = page
        }
    }
    
    /// `UUID` for controlling the order of highlighting
    private var displayHighlightID: UUID?
    
    /// Trigger the highlighting of several rectangles on the specified page.
    ///
    /// When triggered, the page will navigate to the rectangular area highlighted based on the minimum scrolling distance principle.
    ///
    /// - Parameter pageIndex: This parameter represents the index of the page. Index starts from 0.
    /// - Parameter rects: A list of rectangles to be highlighted. These rectangles must be in the page view coordinate system of the PDF, with the origin at the **bottom left corner**.
    /// - Parameter duration: Duration of highlighted. Unit is seconds.
    /// - Parameter color: The color used for highlighting. Default to yellow.
    public final func triggerHighlight(pageIndex: Int, rects: [CGRect], duration: TimeInterval = 0.3, color: UIColor = .yellow) {
        guard let documentModel, let page = documentModel.page(at: pageIndex), let documentView else { return }
        class HighlightView: UIView {}
        if self.displayHighlightID != nil {
            self.documentView?.subviews.filter({ $0 is HighlightView }).forEach {
                $0.removeFromSuperview()
            }
        }
        let newID = UUID()
        self.displayHighlightID = newID
        // Scroll to Viewport
        let allRect = rects.reduce(CGRect.zero) { $0.union($1) }
            .intersection((page as PDFPage).bounds(for: self.displayBox))
        self.go(to: allRect, on: page)
//        // **Not** use `self.go(to: allRect, on: page)` because of minimum scrolling distance principle.
//        let allRectInBounds = self.convert(allRect, from: page)
//        
//        let allRectInDocument = self.convert(allRectInBounds, to: documentView)
//        print(documentView.frame)
//        self.scrollView?.scrollRectToVisible(allRectInDocument.rescale(self.scrollView?.zoomScale ?? 1), animated: false)
        // Add Subviews
        let viewRects = rects
            .map {
                let pageRect = $0.intersection((page as PDFPage).bounds(for: self.displayBox))
                let viewRect = self.convert(pageRect, from: page)
                return self.convert(viewRect, to: documentView)
            }
            .filter { !$0.isNotValid }
        let views = viewRects.map { HighlightView(frame: $0) }
        views.forEach {
            $0.backgroundColor = color
            $0.layer.opacity = 0.3
            documentView.addSubview($0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.3) {
            if newID == self.displayHighlightID {
                self.displayHighlightID = nil
                views.forEach { $0.removeFromSuperview() }
            }
        }
    }
}


//MARK: - Override
@available(iOS 16.0, *)
extension PDFDocumentScrollView {
    
    /// Reports changes in the iOS interface environment.
    @available(iOS, introduced: 16.0, deprecated: 17.0, message: "Use the trait change registration APIs declared in the UITraitChangeObservable protocol")
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateDocumentUserStyle()
    }
    
    /// Tells the delegate a layer's bounds have changed.
    override public func layoutSublayers(of layer: CALayer) {
        self.scrollView?.delegate = self
        super.layoutSublayers(of: layer)
        self.updateScale()
        if self.internalUsingSwiftUI {
            self.documentView?.isUserInteractionEnabled = false
        }
    }
    
    /// Asks the receiving responder to add and remove items from a menu system.
    public override func buildMenu(with builder: any UIMenuBuilder) {
        super.buildMenu(with: builder)
        guard builder.system == UIMenuSystem.context, let document = self.documentModel else {
            return
        }
        for id in UIMenu.Identifier.allCases where id != .root && id != .standardEdit {
            builder.remove(menu: id)
        }
        let menuDisplay: UIMenu.Options = if #available(iOS 17.0, *) { .displayInline } else {
            .displayInline
        }
        // left items
        let setLeadingMenu = {
            let leadingItems = self.leadingSelectionMenuItems.map { item in
                UIAction(title: item.title, image: item.icon) { _ in
                    item.actionHandle(view: self, document: document)
                }
            }
            if leadingItems.isEmpty { return }
            let leadingMenu = UIMenu(options: menuDisplay, children: leadingItems)
            builder.insertChild(leadingMenu, atStartOfMenu: .root)
        }
        // right items
        let setTrailingMenu = {
            let trailingItems = self.trailingSelectionMenuItems.compactMap { item in
                UIAction(title: item.title, image: item.icon) { _ in
                    item.actionHandle(view: self, document: document)
                }
            }
            if trailingItems.isEmpty { return }
            let trailingMenu = UIMenu(options: menuDisplay, children: trailingItems)
            builder.insertChild(trailingMenu, atEndOfMenu: .root)
        }
        setLeadingMenu()
        setTrailingMenu()
    }
    
    /// Performs layout of the inner views.
    @available(*, unavailable)
    public override func layoutDocumentView() {
        super.layoutDocumentView()
        self.hackTileLayerColor()
    }
    
    /// A special hack method used to control colors of tile-layer..
    func hackTileLayerColor() {
        guard let documentModel else { return }
        
        self.documentView?.subviews.forEach { pageView in
            let sublayers = (pageView.layer.sublayers?.first?.sublayers ?? [])
            if sublayers.count >= 2 {
                if (self.traitCollection.userInterfaceStyle == .dark && documentModel.invertRenderingColor)  {
                    sublayers[1].backgroundColor = UIColor.black.cgColor
                } else if (self.traitCollection.userInterfaceStyle == .dark) {
                    sublayers[1].backgroundColor = UIColor.white.cgColor
                } else {
                    sublayers[1].backgroundColor = documentModel.documentColor.pageBackgroundColor.cgColor
                }
            }
        }
    }
    
    
}


//MARK: - Unavailable And Deprecated

@available(iOS 16.0, *)
extension PDFDocumentScrollView {
    @available(*, unavailable)
    public override var pageOverlayViewProvider: (any PDFPageOverlayViewProvider)? {
        didSet {}
    }
    @available(*, unavailable)
    public override var document: PDFDocument? {
        get { super.document }
        set { super.document = newValue }
    }
    /// Returns the current page.
    ///
    /// When there are two pages in the view in a two-up mode, “current page” is the left page. For continuous modes, returns the page crossing a horizontal line halfway between the view’s top and bottom bounds.
    @available(*, deprecated, message: "The value returned by this property is incorrect when scrolling. Please use the `mainPage` property instead.")
    public override var currentPage: PDFPageModel? {
        super.currentPage as? PDFPageModel
    }
    @available(*, unavailable)
    open override var pageShadowsEnabled: Bool { didSet {} }
    @available(*, unavailable)
    override public var visiblePages: [PDFPage] { super.visiblePages }
    @available(*, unavailable)
    override public var minScaleFactor: CGFloat { didSet {} }
    @available(*, unavailable)
    override public var maxScaleFactor: CGFloat { didSet {} }
    @available(*, unavailable)
    override public var scaleFactor: CGFloat { didSet {} }
    @available(*, unavailable)
    override public var scaleFactorForSizeToFit: CGFloat { super.scaleFactorForSizeToFit }
    @available(*, unavailable)
    override public var canGoBack: Bool { super.canGoBack }
    @available(*, unavailable)
    public override var canGoForward: Bool { super.canGoForward }
    @available(*, unavailable)
    public override var canGoToLastPage: Bool { super.canGoToLastPage }
    @available(*, unavailable)
    public override var canGoToNextPage: Bool { super.canGoToNextPage }
    @available(*, unavailable)
    public override var canGoToFirstPage: Bool { super.canGoToFirstPage }
    @available(*, unavailable)
    public override var canGoToPreviousPage: Bool { super.canGoToPreviousPage }
    @available(*, unavailable)
    public override func goBack(_ sender: Any?) {}
    @available(*, unavailable)
    public override func goForward(_ sender: Any?) {}
    @available(*, unavailable)
    public override func goToLastPage(_ sender: Any?) {}
    @available(*, unavailable)
    public override func goToNextPage(_ sender: Any?) {}
    @available(*, unavailable)
    public override func goToFirstPage(_ sender: Any?) {}
    @available(*, unavailable)
    public override func goToPreviousPage(_ sender: Any?) {}
    @available(*, unavailable)
    public override func pasteAndGo(_ sender: Any?) {
        super.pasteAndGo(sender)
    }
}


#endif
