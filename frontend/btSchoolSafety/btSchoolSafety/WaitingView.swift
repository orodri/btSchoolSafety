//
//  WaitingView.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 11/13/22.
//

import SwiftUI

struct WaitingView: View {
    
    var body: some View {
        VStack {
            Spacer()
            Text("Waiting for the system to be activated...")
                .font(.largeTitle)
            Spacer()
            Text("Emergency reported! A first responder will be in touch shortly. In the mean time, dial 911.")
            Spacer()
            Button("Contact an official") {
              
            }
            Spacer()
        }
        .padding()
    }
}

struct WaitingView_Preview: PreviewProvider {
    static var previews: some View {
        WaitingView()
    }
}
