//
//  TextArea.swift
//  AOIOMI
//
//  Created by vlsolome on 3/31/21.
//

import SwiftUI

public struct TextArea: NSViewRepresentable {
    private var text: Binding<String>

    public init(text: Binding<String>) {
        self.text = text
    }

    public func makeNSView(context: Context) -> NSScrollView {
        context.coordinator.createTextViewStack()
    }

    public func updateNSView(_ nsView: NSScrollView, context _: Context) {
        if let textArea = nsView.documentView as? NSTextView, textArea.string != text.wrappedValue {
            textArea.string = text.wrappedValue
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(text: text)
    }

    public class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        public func textView(_ textView: NSTextView, shouldChangeTextIn range: NSRange, replacementString text: String?) -> Bool {
            defer {
                self.text.wrappedValue = (textView.string as NSString).replacingCharacters(in: range, with: text!)
            }
            return true
        }

        fileprivate lazy var textStorage = NSTextStorage()
        fileprivate lazy var layoutManager = NSLayoutManager()
        fileprivate lazy var textContainer = NSTextContainer()
        fileprivate lazy var textView = NSTextView(frame: CGRect(), textContainer: textContainer)
        fileprivate lazy var scrollview = NSScrollView()

        func createTextViewStack() -> NSScrollView {
            let contentSize = scrollview.contentSize

            textContainer.containerSize = CGSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
            textContainer.widthTracksTextView = true

            textView.minSize = CGSize(width: 0, height: 0)
            textView.maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            textView.isVerticallyResizable = true
            textView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
            textView.autoresizingMask = [.width]
            textView.delegate = self

            scrollview.borderType = .noBorder
            scrollview.hasVerticalScroller = true
            scrollview.documentView = textView

            textStorage.addLayoutManager(layoutManager)
            layoutManager.addTextContainer(textContainer)

            return scrollview
        }
    }
}
