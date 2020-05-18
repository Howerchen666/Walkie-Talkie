//
//  SwiftUIView.swift
//  Walkie-Talkie
//
//  Created by Hower Chen on 2020/4/28.
//  Copyright © 2020 Hower Chen. All rights reserved.
//

import SwiftUI

struct main: View {
    @State var walkieTalkie: Bool = false
    @State var room: String = ""
    var body: some View {
        VStack {
            //show content view
            if walkieTalkie == true{
                ContentView(walkieTalkie: $walkieTalkie, room: self.room)
            }
            //show channel config
            if walkieTalkie == false{
                Channel_Config(walkieTalkie: $walkieTalkie, room: $room)
            }
        }
            //adding animation
        .animation(.default)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        main( room:(""))
    }
}
