//
//  ChatHistory.swift
//  btSchoolSafety
//
//  Created by Angel Cheng on 2022/12/7.
//

import Foundation
class ChatHistory: ObservableObject {
    struct message : Hashable{
        let user: String
        let text: String
    }
    @Published var chat_history: [message]
    
    static let shared = ChatHistory()
    public init() {
        chat_history = []
    }
    func add_chat(user:String, text:String){
        chat_history.append(message(user: user, text: text))
    }
    func get_chat_history() -> Array<message>{
        return chat_history
    }
}
