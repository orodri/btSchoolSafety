//
//  PanicSelector.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 11/13/22.
//

import SwiftUI

struct PanicSelector: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Text("What type of incident would you like to report?")
            Spacer()
            Button("Active shooting") {
                Task {
                    System.shared.isWaitingForActivation = true
                    await postPanic(.activeShooting)
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            Spacer()
            Button("Fire") {
                Task {
                    System.shared.isWaitingForActivation = true
                    await postPanic(.fire)
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            Spacer()
            Button("Other") {
                Task {
                    System.shared.isWaitingForActivation = true
                    await postPanic(.other)
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            Spacer()
            Button("Cancel") {
                isPresented.toggle()
            }
        }
        .padding()
    }
}

struct PanicSelector_Preview: PreviewProvider {
    @State static var isPresented = true
    static var previews: some View {
        PanicSelector(isPresented: $isPresented)
    }
}
