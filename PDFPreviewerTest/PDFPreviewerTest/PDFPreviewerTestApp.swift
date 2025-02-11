//
//  PDFPreviewerTestApp.swift
//  PDFPreviewerTest
//
//  Created by 孟超 on 2024/9/26.
//

import SwiftUI
import PDFPreviewer
import FPSMonitorLabel
import PDFKit

let PDFURL = Bundle.main.url(forResource: "test_pdf2", withExtension: "pdf")!


@main
struct PDFPreviewerTestApp: App {
    @State var isShowing = true
    @State var text: String = "123"
    @State var width: CGFloat = 700.0
    @StateObject var pdfModel: PDFPreviewerModel = .init()
    @State var currentTap = 0
    @Environment(\.colorScheme) var colorScheme
    @State var colorNewScheme: ColorScheme = .light
    var body: some Scene {
        WindowGroup {
            VStack {
                //TextField("你好世界", text: $text)
                Spacer()
                HStack {
                    Button("设置双击手势") {
                        if self.pdfModel.interactionDelegate == nil {
                            self.pdfModel.interactionDelegate = Delegate()
                        } else {
                            self.pdfModel.interactionDelegate = nil
                        }
                        class Delegate:PDFPreviewerInteractionDelegate {
                            func didDoubleTap(at documentPosition: PDFPreviewerModel.DocumentPosition) {
                                print("双击了文档: \(documentPosition.point)")
                            }
                            func showMenu(at documentPosition: PDFPreviewerModel.DocumentPosition) -> UIMenu {
                                UIMenu(children: [UIAction(title:"你好", handler: {_ in })])
                            }
                            
                        }
                    }
                    Button("重加载文档") {
                        Task {
                            await self.pdfModel.loadDocument(from: PDFURL, restoreViewportState: true, resignKeyboard: false)
                        }
                    }
                    Button("切换页面主题") {
                        defer { currentTap += 1}
                        self.pdfModel.themeColor = PDFDocumentModel.DocumentColor.allCases[(currentTap % PDFDocumentModel.DocumentColor.allCases.count)]
                    }
                    Button("切换页面阴影") {
                        self.pdfModel.themeColor.pageBorder = ((self.pdfModel.themeColor.pageBorder ==  .default) ?  .dynamicBlack : .default)
                    }
                    Button("切换颜色") {
                        self.pdfModel.invertRenderingColor.toggle()
                    }
                    Button("切换夜间模式") {
                        self.colorNewScheme = (self.colorNewScheme == .dark ? .light : .dark)
                    }
                    Button("锁定缩放") {
                        self.pdfModel.lockingAutoScale.toggle()
                    }
                    Picker("中心缩放等级", selection: self.$pdfModel.trimLevel) {
                        Text("100%").tag(PDFDocumentModel.TrimLevel.percentage0)
                        Text("105%").tag(PDFDocumentModel.TrimLevel.percentage5)
                        Text("110%").tag(PDFDocumentModel.TrimLevel.percentage10)
                        Text("115%").tag(PDFDocumentModel.TrimLevel.percentage15)
                        Text("120%").tag(PDFDocumentModel.TrimLevel.percentage20)
                        Text("125%").tag(PDFDocumentModel.TrimLevel.percentage25)
                    }
                }
                Slider(value: $width, in: 100...800)
                Slider(value: self.$pdfModel.documentScale, in: 0.5...3.0)
                HStack {
                    Text("缩放: \(self.pdfModel.documentScale)")
                    Button("转到第一页") {
                        self.pdfModel.navigation?.go(to: 0)
                    }
                    Button("转到最后一页") {
                        if let nav = self.pdfModel.navigation {
                            nav.go(to: nav.pageIndexRange.endIndex - 1)
                        }
                    }
                    Button("触发第4页的高亮") {
                        if let nav = self.pdfModel.navigation {
                            nav.triggerHighlight(pageIndex: 4, rects: [.init(x: 0, y: 0, width: 100, height: 100), .init(x: 100, y: 100, width: 50, height: 50)])
                        }
                    }
                }
                PDFPreviewer(model: self.pdfModel)
                    .environment(\.colorScheme, self.colorNewScheme)
                    .frame(width: width)
                    .onAppear() {
                        Task {
                            await self.pdfModel.loadDocument(from: PDFURL, restoreViewportState: true, resignKeyboard: false)
                        }
                    }
                
                Spacer()
            }
            .overlay(alignment: .bottomLeading) {
                FPSMonitorLabel()
            }
        }
    }
}


struct TestPDFDocumentUpdate: UIViewRepresentable {
    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.document = PDFDocument(url: PDFURL)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            view.document = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                view.document = PDFDocument(url: PDFURL)
            }
            
        }
        return view
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        
    }
    
    typealias UIViewType = PDFView
    
    
}
