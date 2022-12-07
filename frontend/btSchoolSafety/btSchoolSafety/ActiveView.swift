//
//  ActiveView.swift
//  btSchoolSafety
//
//  Created by Owen Rodriguez on 11/14/22.
//

import SwiftUI

struct ActiveView: View {
    @State var messageView = false
    @State private var showingAlert = false
     @State private var alertType = ""
    var body: some View {
        VStack {
            Group() {
                Spacer()
                Text("There is an active shooting reported at your school")
                    .font(.largeTitle)
                Spacer()
                Text("Your location is not currently being shared with first responders. ❌ To fix this grant location access always in settings:")
                Button("I need medical assistance!") {
                    Task{
                        await postStatus(.medAssistance)
                        showingAlert = true
                        alertType = "I need medical assistance!"
                    }
                }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                Spacer()
            }
            Group() {
                Button("I am safe") {
                    Task{
                        await postStatus(.safe)
                        showingAlert = true
                        alertType = "Safe"
                    }
                }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                Spacer()
                Button("The shooter is near me") {
                    Task{
                        await postStatus(.shooter)
                        showingAlert = true
                        alertType = "Shooter is near me"
                    }
                }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                Spacer()
                Button("Contact an official") {
                    messageView.toggle()
                }.sheet(isPresented: $messageView){
                    MessageView(isPresented:$messageView)
                }
                Spacer()
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Your Status Posted as:"), message: Text(alertType), dismissButton: .default(Text("OK")))
                    }
            }
        }
        .padding()
    }
}

struct ActiveView_Preview: PreviewProvider {
    static var previews: some View {
        ActiveView()
    }
}
