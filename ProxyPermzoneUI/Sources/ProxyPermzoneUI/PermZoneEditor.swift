//
//  PermzoneEditor.swift
//  AOIOMI
//
//  Created by vlsolome on 3/31/21.
//

import Combine
import CommonUI
import SwiftUI

struct PermZoneEditor: View {
    @Binding var permZone: PermZone
    @Binding var isShowingError: Bool
    @Binding var error: Error?

    var body: some View {
        VStack {
            TextField("Name", text: $permZone.name)
            HStack(alignment: .top) {
                TextArea(text: $permZone.body)
            }
        }
        .alert(isPresented: $isShowingError) {
            Alert(
                title: Text("Error"),
                message: Text(error?.localizedDescription ?? "")
            )
        }
        .frame(width: 300, height: 150)
    }
}

#if DEBUG
    struct PermzoneEditor_Previews: PreviewProvider {
        @State static var permZone = PermZone()
        @State static var isShowingError = false
        @State static var error: Error?

        static var previews: some View {
            PermZoneEditor(permZone: $permZone, isShowingError: $isShowingError, error: $error)
        }
    }
#endif
