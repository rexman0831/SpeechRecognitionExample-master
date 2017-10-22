//
//  ViewController.swift
//  SpeechRecognizerDemo
//
//  Created by Hans Knöchel on 14.06.16.
//  Copyright © 2016 Appcelerator. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate, AVAudioPlayerDelegate,UITextFieldDelegate {
    
    //UIと変数の設定
    
    @IBOutlet weak var recordingButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var audioFileName: URL!
    @IBOutlet weak var mytextview: UITextView!
    @IBOutlet weak var mytextfield: UITextField!
    
    @IBAction func recordButton(_ sender: UIButton) {
        recordTapped()
    }
    
    //辞書を開く
    @IBAction func search(_ sender: UIButton) {
    
        if (mytextfield == nil) || (mytextfield.text?.characters.count == 0){
            print("nil")
            
        }else{
            
            let show = mydictionary(term: mytextfield.text!)
            present(show, animated: true, completion: nil)
        }
    }
    
    
    //録音する
     func play(_ sender: Any) {
       
        if !audioRecorder.isRecording {
            self.audioPlayer = try! AVAudioPlayer(contentsOf:self.audioFileName)
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.delegate = self
            self.audioPlayer.play()
            
            
        }
    }
   

   //録音の開始などの設定
    @IBAction func speechRecognizerButton(_ sender: Any) {
    
        
        
        audioRecorder = nil
        
        // Initialize the speech recogniter with your preffered language
        
       guard let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) else {
       
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
                        let show = mydictionary(term: (result?.bestTranscription.formattedString)!)
                            self.present(show, animated: true, completion: nil)
                        print("print完了")
                        }
                    }else{
                        print("resultがnilです")
                        self.mytextview.text.append("recognize error" + "\n")
                    }
                })
            } else {
                print("Error: Speech-API not authorized!");
            }
        }
   }
    
    
    //viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
           
        mytextfield.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
 //                      self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }

    
    //録音のファイル
    func startRecording() {
        
        recordingButton.setTitle("finish", for: .normal)
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
            
            print("recording now")
            
    //        recordButton.setTitle("stop-recognize", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    //音声URL
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    //録音が終わった時の処理
    func finishRecording(success: Bool) {
        print("finish!!")
        audioRecorder.stop()
        
        if success {
       recordingButton.setTitle("re-recognize", for: .normal)
            //recognizeの関数を呼ぶ
            speechRecognizerButton(_sender: (Any).self)
            
            
        } else {
    //        recordButton.setTitle("recognize", for: .normal)
            
            audioRecorder = nil
            
        }
    }
    
    
    
    //色々処理
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
    
    
    //オーディオ関係
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print(flag)
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?){
        print(error.debugDescription)
    }
    internal func audioPlayerBeginInterruption(_ player: AVAudioPlayer){
        print(player.debugDescription)
    }
}

class testclass: ViewController{

    
}

