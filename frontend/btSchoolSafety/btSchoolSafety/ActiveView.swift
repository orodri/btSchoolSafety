//
//  ActiveView.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 11/14/22.
//

import SwiftUI

struct ActiveView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Group() {
                Spacer()
                Text("There is an active shooting reported at your school")
                    .font(.largeTitle)
                Spacer()
                Text("Your location is not currently being shared with first responders. ❌ To fix this grant location access always in settings:")
                Button("I need medical assistance!") {}
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                Spacer()
            }
            Group() {
                Button("I am safe") {

                }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                Spacer()
                Button("The shooter is near me") {

                }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                Spacer()
                Button("Contact an official") {}
                Spacer()
            }
        }
        .padding()
        .onAppear() {
            Task {
                await postRegister()
            }
        }
    }
}

struct ActiveView_Preview: PreviewProvider {
    @State static var isPresented = true
    static var previews: some View {
        ActiveView(isPresented: $isPresented)
    }
}
