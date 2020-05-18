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
        
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
                .frame(width: 80.0, height: 80.0)
                .overlay(Image(systemName: "phone.fill.arrow.up.right").foregroundColor(.black)
                    .font(.title)
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({_ in
                        if self.buttonState == false {
                            self.start()
                        }
                        self.buttonState = true
                    }).onEnded({ _ in
                        self.finished()
                        self.buttonState = false
                    })))
            
            Spacer()
            Button(action: {
                self.webSocketTask.cancel(with: .normalClosure, reason: nil)
                self.walkieTalkie = false
            }) {
                Text("Leave Room")
                    .foregroundColor(.red)
            }
        }.onAppear {
            self.connectWebSocket()
            self.handler.setupRecorder()
            self.handler.setupPlayer()
        }
    }
    
    func start() {
        print("Start")
        self.handler.startRecording()
    }
    
    func finished() {
        print("Finished")
        self.handler.stopRecording()
        let data = try? Data(contentsOf: handler.getDocumentsDirectory().appendingPathComponent(handler.fileName))
        //print(data)
        if data != nil{
            sendDataToWS(data!)
        }
    }
    
    func connectWebSocket() {
        // WebSocket's URL
        let wsURLStr = "ws://walkietalkie.howerchen.cn:900/\(room)"
        let wsURL = URL(string: wsURLStr)!
        
        // Create webSocketTask
        webSocketTask = URLSession.shared.webSocketTask(with: wsURL)
        // Start
        webSocketTask.resume()
        
        receivedFromWS()
    }
    
    func sendDataToWS(_ data: Data) {
        print("Sending data: \(data)")
        // 制造一个message
        let message = URLSessionWebSocketTask.Message.data(data)
        // 发送信息
        webSocketTask.send(message) { error in
            if let error = error {
                // 出错误了
                print("Error sending data: \(error)")
            }
        }
        
        print("Sent data to WS!")
    }
    
    func receivedFromWS() {
        // 接受消息
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                // 失败
                print("Failed to receive message: \(error)")
            case .success(let message):
                switch message {
                case .string(let str):
                    // 接收到字符串
                    print("Received string: \(str)")
                //self.updateReceiveText(str)
                case .data(let data):
                    // 接收到二进制数据
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
    
    func createChunks(for data: Data) -> [Data] {
        var result = [Data]()
        data.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
            let mutRawPointer = UnsafeMutableRawPointer(mutating: u8Ptr)
            let uploadChunkSize = 65536
            let totalSize = data.count
            var offset = 0
            
            while offset < totalSize {
                
                let chunkSize = offset + uploadChunkSize > totalSize ? totalSize - offset : uploadChunkSize
                let chunk = Data(bytesNoCopy: mutRawPointer+offset, count: chunkSize, deallocator: Data.Deallocator.none)
                offset += chunkSize
                
                result.append(chunk)
            }
        }
        return result
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView( walkieTalkie: .constant(false), room: "")
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
        let recordSetting = [ AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey:44100,
        AVNumberOfChannelsKey:1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue] as [String : Any]
        
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
        } catch {
            print(error)
        }
    }
    
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

