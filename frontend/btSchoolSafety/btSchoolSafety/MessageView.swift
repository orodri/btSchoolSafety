//
//  MessageView.swift
//  btSchoolSafety
//
//  Created by Angel Cheng on 2022/12/3.
//

import Foundation
import SwiftUI

struct MessageView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            HStack{
                Spacer()
                Button("Cancel") {
                    isPresented.toggle()
                }
            }
            Spacer()
            Button("HELLLO"
            ){
                
            }
            Spacer()
           
        }
        .padding()
    }
}

struct MessageView_Preview: PreviewProvider {
    @State static var isPresented = true
    static var previews: some View {
        MessageView(isPresented: $isPresented)
    }
}
