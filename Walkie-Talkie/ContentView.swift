//
//  ContentView.swift
//  Walkie-Talkie
//
//  Created by Hower Chen on 2020/4/28.
//  Copyright © 2020 Hower Chen. All rights reserved.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    //creating observable object
    @ObservedObject var handler = WebSocketHandler()
    @State var buttonState: Bool = false
    @State var image = "button"
    @Binding var walkieTalkie: Bool
    @State var webSocketTask: URLSessionWebSocketTask!
    
    var room: String
    
    var body: some View {
        NavigationView {
            ZStack {
                //changing the backgound color to yellow
                Color("background")
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    //status
                    HStack {
                        Text("Server:walkietalkie.howerchen.cn")
                            .padding(.leading)
                        Spacer()
                    }
                    HStack {
                        Text("Channel:\(room)")
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
                        self.webSocketTask.cancel(with: .normalClosure, reason: nil)
                        self.walkieTalkie = false
                    }) {
                        Text("Leave Room")
                            .foregroundColor(Color.red)
                    }
                    .padding(.bottom, 150)
                    
                    NavigationLink(destination: About()) {
                        Text("About")
                    }
                    .padding(.bottom)
                }
                .padding(.top, 14.0)
                .onAppear{
                    self.handler.setupRecorder()
                    self.connectWebSocket()
                }
                .navigationBarTitle("Walkie Talkie", displayMode: .inline)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
    }
    
    func start() {
        print("Start")
        self.handler.startRecording()
    }
    
    func finished() {
        print("Finished")
        self.handler.stopRecording()
        let data = try? Data(contentsOf: handler.getDocumentsDirectory().appendingPathComponent(handler.fileName))
        if data != nil{
            sendDataToWS(data!)
        }
    }
    
    func connectWebSocket() {
        // WebSocket's URL
        let wsURLStr = "ws://walkietalkie.howerchen.cn:8081/\(room)"
        let wsURL = URL(string: wsURLStr)!
        
        // Create webSocketTask
        webSocketTask = URLSession.shared.webSocketTask(with: wsURL)
        // Start
        webSocketTask.resume()
        
        receivedFromWS()
    }
    
    func sendDataToWS(_ data: Data) {
        print("Sending data: \(data)")
        // create message
        let message = URLSessionWebSocketTask.Message.data(data)
        // send message
        webSocketTask.send(message) { error in
            if let error = error {
                // failed
                print("Error sending data: \(error)")
            }
        }
        
        print("Sent data to WS!")
    }
    
    func receivedFromWS() {
        // revieve message
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                // failed
                print("Failed to receive message: \(error)")
            case .success(let message):
                switch message {
                case .string(let str):
                    // recived
                    print("Received string: \(str)")
                //self.updateReceiveText(str)
                case .data(let data):
                    // recived binary
                    print("Received binary: \(data)")
                    self.handler.updateReceiveData(data)
                @unknown default:
                    print("Unknown data type!")
                }
                // Close on failure, only continue when success
                self.receivedFromWS()
            }
        }
    }
}


//Audio recorder
class WebSocketHandler: NSObject, ObservableObject, AVAudioPlayerDelegate , AVAudioRecorderDelegate {
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var AudioPlayer: Bool = false
    var AudioRecorder: Bool = false
    var fileName: String = "audioFile.m4a"
    var decodedFile: String = "receiveAudio.m4a"
    
    func updateReceiveData(_ data: Data) {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(decodedFile)
        do {
            try data.write(to: audioFilename)
            startPlaying()
        } catch {
            print("Failed writing file!")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //print (paths[0].absoluteString)
        return paths[0]
    }
    
    func setupRecorder() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName)
        let recordSetting = [ AVFormatIDKey : kAudioFormatAppleLossless,
                              AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                              AVEncoderBitRateKey : 320000,
                              AVNumberOfChannelsKey : 2,
                              AVSampleRateKey : 44100.2] as [String : Any]
        
        do {
            soundRecorder = try AVAudioRecorder(url: audioFilename, settings: recordSetting )
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
            
        } catch {
            print(error)
        }
    }
    
    func setupPlayer() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(decodedFile)
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
            let audioSession = AVAudioSession.sharedInstance()

            do {
                try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            } catch let error as NSError {
                print("audioSession error: \(error.localizedDescription)")
            }
            
        } catch {
            print(error)
        }
    }
    
    // Recorder
    func startRecording(){
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
            return
        }
        do {
            try session.setActive(true)
        } catch let error as NSError
        {
            print("could not make session active")
            print(error.localizedDescription)
            return
        }
        
        soundRecorder.record()
    }
    
    func stopRecording() {
        soundRecorder.stop()
    }
    
    func startPlaying(){
        self.AudioPlayer = true
        setupPlayer()
        soundPlayer.play()
    }
    
    func stopPlaying() {
        soundPlayer.stop()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView( walkieTalkie: .constant(false), room: "")
    }
}
