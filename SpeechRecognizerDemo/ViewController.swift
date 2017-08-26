//
//  ViewController.swift
//  SpeechRecognizerDemo
//
//  Created by Hans Knöchel on 14.06.16.
//  Copyright © 2016 Appcelerator. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate, AVAudioPlayerDelegate {
    
    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
     @IBOutlet weak var mytextview: UITextView!
    
    var audioFileName: URL!
   
   
    
    
     func play(_ sender: Any) {
       
        
        
        
        if !audioRecorder.isRecording {
            self.audioPlayer = try! AVAudioPlayer(contentsOf:self.audioFileName)
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.delegate = self
            
            self.audioPlayer.play()
        }
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print(flag)
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?){
        print(error.debugDescription)
    }
    internal func audioPlayerBeginInterruption(_ player: AVAudioPlayer){
        print(player.debugDescription)
    }
    
    
    
    
    
   
    @IBAction func speechRecognizerButton(_ sender: Any) {
    
        
        audioRecorder = nil
        
        // Initialize the speech recogniter with your preffered language
        guard let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US")) else {
            print("Speech recognizer is not available for this locale!")
            return
        }
        
        // Check the availability. It currently only works on the device
        if (speechRecognizer.isAvailable == false) {
            print("Speech recognizer is not available for this device!")
            return
        }
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if (authStatus == .authorized) {
                
                let request = SFSpeechURLRecognitionRequest(url: self.audioFileName)
                
                speechRecognizer.recognitionTask(with: request, resultHandler: { (result, error) in
                    print(result?.bestTranscription ?? "")
                    
                    
                    
                    if result !== nil{
                        
                        if (result?.isFinal)!{
                        
                        self.mytextview.text.append((result?.bestTranscription.formattedString)! + "\n")
                        
                        print("print完了")
                        }
                    }else{
                    
                        print("nilですよ")
                        
                        self.mytextview.text.append("recognize error" + "\n")
                    }
                    
                    
                    
                    
                    
                })
            } else {
                print("Error: Speech-API not authorized!");
            }
        }
   }
    
    // MARK: Speech Recognizer Delegate (only called when using the advanced recognition technique)
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("SpeechRecognizer available: \(available)")
    }

    // MARK: Speech Recognizer Task Delegate
    
    func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        print("speechRecognitionDidDetectSpeech")
    }
    
    func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        print("speechRecognitionTaskFinishedReadingAudio")
    }
    
    func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
        print("speechRecognitionTaskWasCancelled")
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        print("didFinishSuccessfully")
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didRecord audioPCMBuffer: AVAudioPCMBuffer) {
        print("didRecord")
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        print("didHypothesizeTranscription")
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        print("didFinishRecognition")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
           
        
        
        // Do any additional setup after loading the view, typically from a nib.
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                       self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    func loadRecordingUI() {
        //サブ的な
        
        
       // recordButton.backgroundColor = UIColor.red
        //メイン的な
        recordButton = UIButton(frame: CGRect(x: 8, y: 74, width: 359, height: 585))
        recordButton.setTitle("Record", for: .normal)
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        recordButton.setTitleColor(UIColor.blue, for: .normal)
       
       
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(recordButton)
    }
    
    //↓ is not working
    @IBAction func recordButton(_ sender: Any) {
        
        
    }
    
    
    
    
    func startRecording() {
        // here
        
        
        //↓　is written by luke.
       // audioFileName = Bundle.main.bundleURL.appendingPathComponent("recording.m4a")
        
        
        
        
        
        
        //↓It's will be working
        audioFileName = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        
        
        
        
        
        
        print(String(describing: audioFileName))
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.delegate = self as? AVAudioRecorderDelegate
            audioRecorder.record()
            
            print("koko")
            
            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func finishRecording(success: Bool) {
        print("finish!!")
        audioRecorder.stop()
        
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
            //recognizeの関数を呼ぶ
            speechRecognizerButton(_sender: (Any).self)
            
            
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            
            /*
            下買えたから
            
            */
            
            audioRecorder = nil
            
            // recording failed :(
        }
    }
    
    
    
    
    
    func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    
    
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
