//
//  HomeView.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 11/12/22.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Your location is not being shared right now.")
            Spacer()
            Text("Your app permissions are set correctly. ✅")
            Spacer()
            Button("PANIC") {
                Task {
                    await postPanic()
                }
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .controlSize(.large)
            Spacer()
            Text("Hold the panic button for 3 seconds to activate.")
            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
