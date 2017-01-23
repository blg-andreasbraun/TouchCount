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
    
    private var count: Int64 = 0
    private var seconds: Int64 = 0
    
    private var timer: Timer? = nil
    private var startTimeInterval: TimeInterval = 0
    
    private var observer: NSObjectProtocol?
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
            observer = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observer = NotificationCenter.default.addObserver(forName: .UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main) { (note) in
            self.pauseResumeButtonPressed(self.pauseResumeButton)
        }
        
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
        
        timerLabel.text = timeString(from: TimeInterval(seconds))
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
        saveIfNeeded()
        
        count = 0
        seconds = 0
        
        timer?.invalidate()
        timer = nil
        
        isRunning = false
        
        updateUI()
    }
    
    private func saveIfNeeded() {
        if isRunning {
            let tmpCount = count
            let tmpSeconds = seconds
            
            let alertController = UIAlertController(title: NSLocalizedString("Save Entry?", comment: ""), message: nil, preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                textField.placeholder = NSLocalizedString("Name", comment: "")
            }
            
            let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default, handler: { (action) in
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                let entry = TimeEntry(context: appDelegate.persistentContainer.viewContext)
                entry.name = alertController.textFields?.first?.text
                entry.date = NSDate()
                entry.count = Int64(tmpCount)
                entry.duration = Int64(tmpSeconds)
                
                appDelegate.saveContext()
            })
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Discard", comment: ""), style: .default, handler: nil)
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(count, forKey: "count")
        coder.encode(seconds, forKey: "seconds")
        
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        count = coder.decodeInt64(forKey: "count")
        seconds = coder.decodeInt64(forKey: "seconds")
        
        updateUI()
        
        super.decodeRestorableState(with: coder)
    }
}



