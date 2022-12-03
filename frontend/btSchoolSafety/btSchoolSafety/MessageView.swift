//
//  MessageView.swift
//  btSchoolSafety
//
//  Created by Angel Cheng on 2022/12/3.
//

import Foundation
import SwiftUI

struct MessageView: View {
    @Binding var isPresented: Bool
    @State private var text: String = ""
    var body: some View {
        VStack {
            HStack{
                Spacer()
                Button("Cancel") {
                    isPresented.toggle()
                }
            }
            NavigationView {
//                Form {
//                    Section {
//                        Text("Hello, world!")
//                    }
//                    Section{
//                        Text("Hi ")
//                    }
//                }
                List(){}
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Officer")
            }
           
            Spacer()
            TextField(
                "Type a message ...",
                text: $text
            ).onSubmit {
                print($text)
                self.text = ""
            }
           
        }
        .padding()
    }
}

struct MessageView_Preview: PreviewProvider {
    @State static var isPresented = true
    static var previews: some View {
        MessageView(isPresented: $isPresented)
    }
}
