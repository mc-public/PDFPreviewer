//
//  PDFPreviewerTestApp.swift
//  PDFPreviewerTest
//
//  Created by 孟超 on 2025/2/11.
//

import SwiftUI
import PDFPreviewer
import FPSMonitorLabel
import PDFKit


@main
struct PDFPreviewerTestApp: App {
    
    static let TestPDFURL = {
        guard let pdfURL = Bundle.main.url(forResource: "Test", withExtension: "pdf") else {
            fatalError()
        }
        return pdfURL
    }()
    
    @StateObject var pdfModel = PDFPreviewerModel()
    @State var previewerWidth: CGFloat = 0.0
    @State var colorScheme = ColorScheme.light
    @State var isDisplayingController = false
    @State var windowSize: CGSize = .zero
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                PDFPreviewer(model: pdfModel)
                    .frame(width: previewerWidth)
                    .border(.bar, width: 2.0)
                    .navigationTitle("PDF Previewer Test")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbar(content: { toolbar })
            }
            .task {
                await pdfModel.loadDocument(from: Self.TestPDFURL)
            }
            .sheet(isPresented: $isDisplayingController) {
                List {
                    controller
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled)
                .environment(\.colorScheme, colorScheme)
            }
            .environment(\.colorScheme, colorScheme)
            .overlay(alignment: .topLeading) {
                FPSMonitorLabel()
            }
            .onGeometryChange(for: CGSize.self, of: { $0.size }) { newValue in
                previewerWidth = newValue.width
                windowSize = newValue
            }
        }
    }
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Open Settings Panel", systemImage: "gear") {
                isDisplayingController = true
            }
        }
    }
    
    @ViewBuilder
    var controller: some View {
        Section("Document And Gesture") {
            Button("Reload Document") {
                Task {
                    await pdfModel.loadDocument(from: Self.TestPDFURL, restoreViewportState: true, resignKeyboard: false)
                }
            }
            let isUsingDoubleTapGesture = (pdfModel.interactionDelegate == nil)
            Button((isUsingDoubleTapGesture ? "Setup" : "Cancel") + " Double Tap Gesture") {
                if pdfModel.interactionDelegate == nil {
                    pdfModel.interactionDelegate = Delegate()
                } else {
                    pdfModel.interactionDelegate = nil
                }
                class Delegate: PDFPreviewerInteractionDelegate {
                    func didDoubleTap(at documentPosition: PDFPreviewerModel.DocumentPosition) {
                        print("Did double tap document: \(documentPosition.point)")
                    }
                }
            }
        }
        Section("Zoom And Trim") {
            Toggle("Lock Automatic Zoom", isOn: $pdfModel.lockingAutoScale)
            Picker("PDF Trim Level", selection: $pdfModel.trimLevel) {
                Text("100%").tag(PDFDocumentModel.TrimLevel.percentage0)
                Text("105%").tag(PDFDocumentModel.TrimLevel.percentage5)
                Text("110%").tag(PDFDocumentModel.TrimLevel.percentage10)
                Text("115%").tag(PDFDocumentModel.TrimLevel.percentage15)
                Text("120%").tag(PDFDocumentModel.TrimLevel.percentage20)
                Text("125%").tag(PDFDocumentModel.TrimLevel.percentage25)
            }
            SliderUnit(title: "PDF Previewer Width") {
                Text("\(previewerWidth)")
            } slider: {
                Slider(value: $previewerWidth, in: (0.2 * windowSize.width)...(windowSize.width))
            }
            SliderUnit(title: "Document Scale") {
                Text("\(pdfModel.documentScale)")
            } slider: {
                Slider(value: $pdfModel.documentScale, in: 0.5...3.0)
            }
        }
        Section("Theme Style") {
            themePicker
            Picker("Page Shadow", selection: $pdfModel.themeColor.pageBorder) {
                Text("Default").tag(PDFDocumentModel.PageBorder.default)
                Text("Black-White").tag(PDFDocumentModel.PageBorder.dynamicBlack)
            }
            Toggle("Invert Color in Dark Mode", isOn: $pdfModel.invertRenderingColor)
            Button("Toggle Environment ColorScheme") {
                colorScheme = (colorScheme == .dark ? .light : .dark)
            }
        }
        Section("Navigation") {
            Button("Go to First Page") {
                pdfModel.navigation?.go(to: 0)
            }
            Button("Go to Last Page") {
                if let nav = pdfModel.navigation {
                    nav.go(to: nav.pageIndexRange.endIndex - 1)
                }
            }
        }
    }
    
    var themePicker: some View {
        HStack {
            Text("Theme")
            Spacer()
            Menu {
                Picker("Background Theme", selection: $pdfModel.themeColor) {
                    ForEach(PDFDocumentModel.DocumentColor.allBuildThemes, id: \.self) { tag in
                        Image(systemName: "circle.fill")
                            .tint(Color(tag.pageBackgroundColor))
                            .tag(tag)
                    }
                }
                .pickerStyle(.palette)
            } label: {
                Image(systemName: "circle.fill")
                    .foregroundStyle(Color(pdfModel.themeColor.pageBackgroundColor))
                    .shadow(radius: 1.0)
            }
        }
    }
    
    
    var highlightButton: some View {
        Button("Trigger highlight in 4-th page") {
            if let nav = pdfModel.navigation {
                nav.triggerHighlight(pageIndex: 4, rects: [.init(x: 0, y: 0, width: 100, height: 100), .init(x: 100, y: 100, width: 50, height: 50)])
            }
        }
    }
}


struct SliderUnit<Icon: View, Label: View, ValueLabel: View>: View {
    var title: LocalizedStringKey
    var icon: () -> Icon
    var slider: () -> Slider<Label, ValueLabel>
    var body: some View {
        VStack {
            HStack {
                Text(title)
                Spacer()
                icon()
                    .foregroundStyle(.secondary)
            }
            slider()
        }
    }
}
