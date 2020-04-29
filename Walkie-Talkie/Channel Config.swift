//
//  Channel Config.swift
//  Walkie-Talkie
//
//  Created by Hower Chen on 2020/4/28.
//  Copyright © 2020 Hower Chen. All rights reserved.
//

import SwiftUI

struct Channel_Config: View {
    @Binding var walkieTalkie: Bool
    var body: some View {
        ZStack {
            Color("background").edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                HStack {
                    TextField("Enter Channel Number", text: .constant(""))
                    .modifier(DefaultTextFieldStyle())
                    .keyboardType(.numberPad)
                }
                .padding(.horizontal, 21.0)
                
                
                Button(action: {
                    //change to ContentView.Swift
                    self.walkieTalkie = true
                }) {
                    Text("Go!")
                }
                .padding(.top, 80.0)
                Spacer()
            }
        }
    }
}

struct DefaultTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

struct Channel_Config_Previews: PreviewProvider {
    static var previews: some View {
        Channel_Config(walkieTalkie: .constant(true))
    }
}
