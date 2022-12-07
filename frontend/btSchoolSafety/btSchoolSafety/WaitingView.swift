//
//  WaitingView.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 11/13/22.
//

import SwiftUI

struct WaitingView: View {
    
    @State var isPresenting: Bool
    @State var messageView = false
    
    var body: some View {
        VStack {
            Spacer()
            Text("Waiting for the system to be activated...")
                .font(.largeTitle)
            Spacer()
            Text("Emergency reported! A first responder will be in touch shortly. In the mean time, dial 911.")
            Spacer()
            Button("Contact an official") {
                messageView.toggle()
            }.sheet(isPresented: $messageView){
                MessageView(isPresented:$messageView)
            }
            Spacer()
        }
        .padding()
        .fullScreenCover(isPresented: $isPresenting) {
            ActiveView()
        }
    }
}

struct WaitingView_Preview: PreviewProvider {
    static var previews: some View {
        WaitingView(isPresenting: false)
    }
}
