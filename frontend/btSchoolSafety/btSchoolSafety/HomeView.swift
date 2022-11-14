//
//  HomeView.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 11/12/22.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject private var system = System.shared
    @State private var isPresenting = false
    
    var body: some View {
        if (system.isWaitingForActivation) {
            WaitingView()
        } else {
            VStack {
                Spacer()
                Text("Your location is not being shared right now.")
                Spacer()
                Text("Your app permissions are set correctly. ✅")
                Spacer()
                Button("PANIC") {
                    isPresenting.toggle()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .controlSize(.large)
                Spacer()
                Text("Hold the panic button for 3 seconds to activate.")
                Spacer()
            }
            .padding()
            .fullScreenCover(isPresented: $isPresenting) {
                PanicSelector(isPresented: $isPresenting)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
