//
//  ContentView.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 11/12/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundColor(.accentColor)
//            Text("Hello, world!")
            Button("Panic Button") { print("Panic Button tapped!")
            }.padding()
            .tint(.red)
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
