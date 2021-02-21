//
//  ErrorView.swift
//  CoupangMobileApp
//
//  Created by vlsolome on 2/11/21.
//

import SwiftUI

private struct ErrorButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(width: 25, height: 10)
            .foregroundColor(Color.black)
            .background(Color.red)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

struct ErrorDetailView: View {
    let text: String
    @Binding var isShowing: Bool

    var body: some View {
        VStack {
            ScrollView{
                Text(text)
                    .lineLimit(nil)
            }
            HStack {
                SwiftUI.Button("Copy") {
                    let pasteboard = NSPasteboard.general
                    pasteboard.declareTypes([.string], owner: nil)
                    pasteboard.setString(text, forType: .string)
                    isShowing.toggle()
                }
                SwiftUI.Button("Close") {
                    isShowing.toggle()
                }
            }
            .padding()
            .frame(alignment: .trailing)
        }
    }
}

struct ErrorView: View {
    let error: Error?
    @State private var isShowingError: Bool = false

    var body: some View {
        VStack {
            if let error = error {
                SwiftUI.Button(action: {
                    isShowingError.toggle()
                }) {
                    Text("error")
                        .font(Font.system(size: 8, design: .rounded))
                        .foregroundColor(.white)
                }
                .buttonStyle(ErrorButtonStyle())
                .sheet(isPresented: $isShowingError) {
                    ErrorDetailView(text: error.localizedDescription, isShowing: $isShowingError)
                        .frame(maxWidth: 300)
                }
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        let error = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: """
        is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's
        standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
        """])
        ErrorView(error: error)
    }
}
