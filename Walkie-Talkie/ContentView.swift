//
//  ContentView.swift
//  Walkie-Talkie
//
//  Created by Hower Chen on 2020/4/28.
//  Copyright © 2020 Hower Chen. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var buttonState: Bool = false
    @State var image = "button"
    @Binding var walkieTalkie: Bool
    
    var body: some View {
        ZStack {
            //changing the backgound color to yellow
            Color("background").edgesIgnoringSafeArea(.all)
           
            VStack {
                //status
                HStack {
                    Text("Server:")
                        .padding(.leading)
                    Spacer()
                }
                HStack {
                    Text("Delay:")
                        .padding(.leading)
                    Spacer()
                }
                HStack {
                    Text("Channel:")
                        .padding(.leading)
                    Spacer()
                }
                
                
                Spacer()
                //button
                Image(image)
                    .resizable()
                    .frame(width:186,height: 186)
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({_ in
                        if self.buttonState == false {
                            self.start()
                            self.image = "buttonPress"
                        }
                        self.buttonState = true
                    }).onEnded({ _ in
                        self.finished()
                        self.buttonState = false
                        self.image = "button"
                    }))
                Spacer()
                //leave room button
                Button(action: {
                    self.walkieTalkie = false
                }) {
                    Text("Leave Room")
                        .foregroundColor(Color.red)
                }
                .padding(.bottom, 150)
            }
            .padding(.top, 14.0)
        }
        
    }
    
    func start() {
        print("Start")
    }
    
    func finished() {
        print("Finished")
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView( walkieTalkie: .constant(false))
    }
}
