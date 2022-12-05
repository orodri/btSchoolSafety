//
//  WaitingView.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 11/13/22.
//

import SwiftUI

struct WaitingView: View {
    
    @State var isPresenting: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Text("Waiting for the system to be activated...")
                .font(.largeTitle)
            Spacer()
            Text("Emergency reported! A first responder will be in touch shortly. In the mean time, dial 911.")
            Spacer()
            Button("Contact an official") {
                MessageView(isPresented: $isPresenting)
            }
            Spacer()
            Button("Activate (for demo)") {
                isPresenting.toggle()
            }
            Spacer()
        }
        .padding()
        .onAppear() {
            
        }
        .fullScreenCover(isPresented: $isPresenting) {
            ActiveView(isPresented: $isPresenting)
        }
    }
}

struct WaitingView_Preview: PreviewProvider {
    static var previews: some View {
        WaitingView(isPresenting: false)
    }
}
