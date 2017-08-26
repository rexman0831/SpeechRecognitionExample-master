//
//  titlecontroller.swift
//  SpeechRecognizerDemo
//
//  Created by Reiji Okano on 2017/08/10.
//  Copyright © 2017年 Appcelerator. All rights reserved.
//
import UIKit
import Foundation


class titlecontroller: UIViewController {
    
    
    
    @IBOutlet weak var myButton: UIButton!
    @IBOutlet weak var creditsButton: UIButton!
    @IBOutlet weak var howToUseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myButton.backgroundColor = UIColor.orange
        myButton.frame.size = CGSize(width: 125, height: 125)
        myButton.layer.masksToBounds = true
        myButton.layer.cornerRadius = 62.5
        
        creditsButton.backgroundColor = UIColor.blue
        creditsButton.frame.size = CGSize(width: 75, height: 75)
        creditsButton.layer.masksToBounds = true
        creditsButton.layer.cornerRadius = 37.5
        
        howToUseButton.backgroundColor = UIColor.blue
        howToUseButton.frame.size = CGSize(width: 75, height: 75)
        howToUseButton.layer.masksToBounds = true
        howToUseButton.layer.cornerRadius = 37.5

    }
    
    
    
}
