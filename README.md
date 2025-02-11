### PDFPreviewer - a powerful SwiftUI view for iOS platform to display PDF files.

**PDFPreviewer** uses Apple's [PDFKit](https://developer.apple.com/documentation/pdfkit) to display PDF files. And it added features that were originally thought to be impossible within the framework.

![](https://img.shields.io/badge/Platform_Compatibility-iOS16.0+-blue)
![](https://img.shields.io/badge/Swift_Compatibility-6.0-red)

## Features

- Smoothly display PDF files.
- Custom background color and page border.
- Custom page double-click operation.
- Automatically invert the PDF rendering tone in night mode.
- A very simple and powerful zoom-scale control system, allow auto scaling, fixed scaling ratio, or even disable scaling.
- A convenient and easy-to-use PDF page navigation system.

## Example

After downloading the package resources, open the test project to quickly test all the features provided by this framework. The following are two screenshots that demonstrate some of the features supported by the framework.

[Green Background](Images/green.png)

[Inverted Background](Images/green.png)

## Usage

#### Create a `PDFPreviewer` using the view model

```swift
import SwiftUI
import PDFPreviewer

struct ContentView: View {

    static let TestPDFURL: URL = {
        guard let pdfURL = Bundle.main.url(forResource: "Test", withExtension: "pdf") else {
            fatalError()
        }
        return pdfURL
    }()
    
    @StateObject var controller = PDFPreviewerModel()
    var body: some View {
        PDFPreviewer(model: controller)
        .task {
            await controller.loadDocument(from: Self.TestPDFURL)
        }
    }
}
```
Ensure the uniqueness of the view model being passed, otherwise it will result in undefined behavior.

## Contributing

Clone this repository to get started working on the project. 

```bash
git clone --recursive git@github.com:mc-public/PDFPreviewer.git
```






