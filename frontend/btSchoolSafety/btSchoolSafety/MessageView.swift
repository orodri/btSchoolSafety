//
//  MessageView.swift
//  btSchoolSafety
//
//  Created by Angel Cheng on 2022/12/5.
//

import Foundation
import SwiftUI

struct MessageView: View {
    @Binding var isPresented: Bool
    @State private var text: String = ""
//    @State private var chat_history = ChatHistory.shared.chat_history;
    @ObservedObject private var chatObject = ChatHistory()
    
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Button("Cancel") {
                    isPresented.toggle()
                }
            }
            NavigationView {
                VStack(){
                    ForEach(ChatHistory.shared.get_chat_history(), id: \.self) { chat in
                        HStack(){
                            Spacer()
                            Text(chat.text)
                                .padding()
                                .foregroundColor(.white)
                                .background(
                                    Color(UIColor.lightGray)
                                )
                                .cornerRadius(25)
                        }
                    }
                    Spacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Officer")
            }
           
            Spacer()
            ZStack(){
                TextField(
                    "Type a message ...",
                    text: $text
                ).onSubmit {
                    print(text)
                    ChatHistory.shared.add_chat(user: "You", text: text)
                    LocationTrackingService.shared.beginSendChat(text: text)
                    self.text = ""
                }
                .padding(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(UIColor.lightGray), lineWidth: 2)
                )
                .padding()
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
