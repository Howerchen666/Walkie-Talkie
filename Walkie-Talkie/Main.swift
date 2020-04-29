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
    var body: some View {
        VStack {
            if walkieTalkie == true{
                ContentView(walkieTalkie: $walkieTalkie)
            }
            else{
                Channel_Config(walkieTalkie: $walkieTalkie)
            }
        }
        .animation(.default)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        main()
    }
}
