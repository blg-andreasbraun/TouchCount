//
//  TouchCounterViewController.swift
//  TouchCount
//
//  Created by Andreas Braun on 23.01.17.
//  Copyright © 2017 Andreas Braun. All rights reserved.
//

import UIKit

class TouchCounterViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var pauseResumeButton: UIButton!
    
    private var isRunning: Bool = false {
        didSet {
            pauseResumeButton?.setTitle(isRunning ? NSLocalizedString("Pause", comment: "") : NSLocalizedString("Resume", comment: ""), for: .normal)
        }
    }
    
    private var count: Int = 0
    private var seconds: TimeInterval = 0
    
    private var timer: Timer? = nil
    private var startTimeInterval: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isRunning = false
        
        updateUI()
    }

    @IBAction func processTouch(sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            startTimerIfNeeded()
            incrementCounter()
        default:
            // nothing to do here
            break
        }
    }
    
    @IBAction func pauseResumeButtonPressed(_ sender: UIButton) {
        if isRunning {
            timer?.invalidate()
        } else {
            startTimerIfNeeded()
        }
        
        isRunning = !isRunning
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        reset()
    }
    
    private func updateUI() {
        counterLabel.text = "\(count)"
        
        timerLabel.text = timeString(from: seconds)
    }
    
    private func update(timer: Timer) {
        DispatchQueue.main.async {
            self.incrementSeconds()
        }
    }
    
    private func startTimerIfNeeded() {
        if timer == nil || !timer!.isValid {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: update)
        }
    }
    
    private func incrementCounter() {
        if !isRunning {
            isRunning = true
        }
        
        count += 1
        
        updateUI()
    }
    
    private func incrementSeconds() {
        seconds += 1
        
        updateUI()
    }
    
    private func reset() {
        count = 0
        seconds = 0
        
        timer?.invalidate()
        timer = nil
        
        updateUI()
    }
    
    func timeString(from time: TimeInterval) -> String {
        
        let hours = Int(time) / (60 * 60)
        let minutes = (Int(time) / 60) % 60
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
}

