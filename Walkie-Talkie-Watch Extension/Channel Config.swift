//
//  Channel Config.swift
//  Walkie-Talkie
//
//  Created by Hower Chen on 2020/5/6.
//  Copyright © 2020 Hower Chen. All rights reserved.
//

import SwiftUI

struct Channel_Config: View {
    @Binding var walkieTalkie: Bool
    @Binding var room: String
    
    var body: some View {
            VStack {
                HStack {
                    TextField("Channel", text:$room)
                    .modifier(DefaultTextFieldStyle())
                }
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Button(action: {
                    //change to ContentView.Swift
                    self.walkieTalkie = true
                }) {
                    Text("Go!")
                }
                Spacer()
            }
    }
}

struct DefaultTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}

struct Channel_Config_Previews: PreviewProvider {
    static var previews: some View {
        Channel_Config(walkieTalkie: .constant(true), room: .constant(""))
    }
}

