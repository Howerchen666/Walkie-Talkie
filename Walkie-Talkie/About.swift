//
//  About.swift
//  Walkie-Talkie
//
//  Created by Hower Chen on 2020/4/29.
//  Copyright © 2020 Hower Chen. All rights reserved.
//

import SwiftUI

struct About: View {
    var body: some View {
            ZStack {
                //changing the backgound color to yellow
                Color("background")
                    .edgesIgnoringSafeArea(.all)
                
                VStack{
                    Text("About")
                        .font(.headline)
                    Spacer()
                    Image("AboutIcon")
                        .resizable()
                        .frame(width:186,height: 186)
                        .cornerRadius(25)
                        .shadow(color: .gray, radius: 30)
                    Text("Version: 1.0")
                    Spacer()
                    
                    Text("Copyright © 2020 Hower Chen. All rights reserved.")
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
                .padding(.vertical, 16.0)
            }
        }
    }

struct About_Previews: PreviewProvider {
    static var previews: some View {
        About()
    }
}
