//
//  MainVC.swift
//  LivingRoomRemote
//
//  Created by Koji Gardiner on 9/20/17.
//  Copyright © 2017 Koji Gardiner. All rights reserved.
//

import UIKit
import CoreBluetooth

class MainVC: UIViewController, BluetoothSerialDelegate, UITextFieldDelegate {

    //}, CBCentralManagerDelegate, CBPeripheralDelegate {

    // MARK: Properties
    @IBOutlet weak var tvOnButton: RoundedCornerButton!
    @IBOutlet weak var appleTvOnButton: RoundedCornerButton!
    @IBOutlet weak var gameOnButton: RoundedCornerButton!
    
    @IBOutlet weak var tvSwitchButton: RoundedCornerButton!
    @IBOutlet weak var appleTvSwitchButton: RoundedCornerButton!
    @IBOutlet weak var gameSwitchButton: RoundedCornerButton!
    
    @IBOutlet weak var volumeDownButton: RoundedCornerButton!
    @IBOutlet weak var volumeUpButton: RoundedCornerButton!
    @IBOutlet weak var volumeMuteButton: RoundedCornerButton!
    
    @IBOutlet weak var channelUpButton: RoundedCornerButton!
    @IBOutlet weak var channelDownButton: RoundedCornerButton!
    
    @IBOutlet weak var refreshButton: RoundedCornerButton!
    @IBOutlet weak var shutdownButton: RoundedCornerButton!
    
    @IBOutlet weak var connectedLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var touchpadButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
        
    var isConnected: Bool = false {
        didSet {
            updateConnectedLabel()
        }
    }
    
    var controlState: ControlState = .TurnOn {
        didSet {
            updateOnSwitchButtons()
        }
    }
    
    var isActivityRunning: Bool = false
    
    var timer: Timer?   // used for longpress gestures and timing between remote code firing

    // For activity indicator
    var activityAlertController: UIAlertController!
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register for callback when keyboard changes so we can shift position of the textfield
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Set up on-press images for buttons
        tvOnButton.setImage(UIImage(named: "TV-White-Fill"), for: .highlighted)
        appleTvOnButton.setImage(UIImage(named: "AppleTV-White-Fill"), for: .highlighted)
        gameOnButton.setImage(UIImage(named: "Game-White-Fill"), for: .highlighted)
        
        tvSwitchButton.setImage(UIImage(named: "TV-Color"), for: .highlighted)
        appleTvSwitchButton.setImage(UIImage(named: "AppleTV-Color"), for: .highlighted)
        gameSwitchButton.setImage(UIImage(named: "Game-Color"), for: .highlighted)
        
        volumeDownButton.setImage(UIImage(named: "VolumeDown-White-Fill"), for: .highlighted)
        volumeUpButton.setImage(UIImage(named: "VolumeUp-White-Fill"), for: .highlighted)
        
        volumeMuteButton.setImage(UIImage(named: "VolumeMute-White-Fill"), for: .highlighted)
        
        refreshButton.setImage(UIImage(named: "Refresh-Color"), for: .highlighted)
        shutdownButton.setImage(UIImage(named: "Shutdown-Color"), for: .highlighted)
        
        textField.returnKeyType = .done
        
        activityAlertController = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        updateConnectedLabel()
        updateOnSwitchButtons()
        
        serial = BluetoothSerial.init(delegate: self)
        
        //AppleTVKeyboard.init()
        textField.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Keyboard Notification
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        self.textFieldBottomConstraint.constant = self.textFieldBottomConstraint.constant + keyboardFrame.size.height
        self.titleTopConstraint.constant = self.titleTopConstraint.constant - (keyboardFrame.size.height)
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.textFieldBottomConstraint.constant = self.textFieldBottomConstraint.constant - (keyboardFrame.size.height)
        self.titleTopConstraint.constant = self.titleTopConstraint.constant + (keyboardFrame.size.height)
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func serialDidChangeState() {
        switch serial.centralManager.state {
        case .poweredOff:
            print("BLE hardware is powered off")
            serial.stopScan()
        case .poweredOn:
            print("BLE hardware is powered on and ready")
            serial.startScan()
        case .unauthorized:
            print("BLE state is unauthorized")
            serial.stopScan()
        case .unknown:
            print("BLE state is unknown")
            serial.stopScan()
        case .unsupported:
            print("BLE state is unsupported")
            serial.stopScan()
        default:
            print("Error: BLE state not recognized")
            serial.stopScan()
        }
        isConnected = serial.isReady
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        print("Peripheral disconnected")
        isConnected = serial.isReady
    }
    
    /// Called when a message is received
    func serialDidReceiveString(_ message: String) {
        //print("Received string: \(message)")
    }
    
    /// Called when a message is received
    func serialDidReceiveBytes(_ bytes: [UInt8]) {
        //print("Received bytes: \(bytes)")
    }
    
    /// Called when a message is received
    func serialDidReceiveData(_ data: Data) {
        //print("Received data: \(data)")
    }
    
    /// Called when the RSSI of the connected peripheral is read
    func serialDidReadRSSI(_ rssi: NSNumber) {
        print("Read RSSI: \(rssi)")
    }
    
    /// Called when a new peripheral is discovered while scanning. Also gives the RSSI (signal strength)
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        print("Peripheral discovered: \(peripheral.name ?? "nil")")
        serial.connectToPeripheral(peripheral)
    }
    
    /// Called when a peripheral is connected (but not yet ready for communication)
    func serialDidConnect(_ peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral.name ?? "nil")")
        isConnected = serial.isReady
    }
    
    /// Called when a pending connection failed
    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {
        print("Failed to connect to peripheral \(peripheral.name ?? "nil")")
    }
    
    /// Called when a peripheral is ready for communication
    func serialIsReady(_ peripheral: CBPeripheral) {
        isConnected = serial.isReady
    }
    
    func updateConnectedLabel() {
        if isConnected {
            connectedLabel.text = "Connected"
            connectedLabel.textColor = UIColor.green
            
            
        } else {
            connectedLabel.text = "Not Connected"
            connectedLabel.textColor = UIColor.red
        }
    }
    
    func updateOnSwitchButtons() {
        switch controlState {
        case .TurnOn:
            tvOnButton.isHidden = false
            appleTvOnButton.isHidden = false
            gameOnButton.isHidden = false
            
            tvSwitchButton.isHidden = true
            appleTvSwitchButton.isHidden = true
            gameSwitchButton.isHidden = true
        case .SwitchTo:
            tvOnButton.isHidden = true
            appleTvOnButton.isHidden = true
            gameOnButton.isHidden = true
            
            tvSwitchButton.isHidden = false
            appleTvSwitchButton.isHidden = false
            gameSwitchButton.isHidden = false
        }
    }
    
    func sendAppleTVText(text: String) {
        if text == "" { return }
        
        let delayInMilliseconds: Int = 150
        var textWithClear = text
        
        textWithClear.insert("_", at: text.index(text.startIndex, offsetBy: 0))  // insert the "clear" key first
        print("Sending text to AppleTV: \(textWithClear)")
        
        let codes = AppleTVKeyboard.instance.remoteCodesFor(string: textWithClear)
        print(codes)
    
        sendRemoteCodesWithDelay(codes: codes, delayInMilliseconds: delayInMilliseconds)
    }

    func sendRemoteCodesWithDelay(codes: [RemoteCode], delayInMilliseconds: Int) {

        for code in codes {

            // TODO: Make this nonblocking
            serial.sendMessageToDevice("\(code.rawValue)\n")
            usleep(UInt32(delayInMilliseconds * 1_000))
        }
//        showActivityIndicator()
//        for (index,code) in codes.enumerated() {
//
//            let when = DispatchTime.now() + DispatchTimeInterval.milliseconds(delayInMilliseconds * index)
//            DispatchQueue.main.asyncAfter(deadline: when) {
//                print("\(index): \(codes[index]) at \(DispatchTime.now().rawValue)")
//                serial.sendMessageToDevice("\(code.rawValue)\n")
//                //usleep(UInt32(delayInSeconds * 1_000_000))
//                if index == codes.count-1 {     // if we just finished the last one in the loop
//                    self.hideActivityIndicator()
//                }
//            }
//        }
        
//        showActivityIndicator()
//        for (index,code) in codes.enumerated() {
//            let delay = Double(delayInMilliseconds) / 1000.0 * Double(index)
//            var isLastIndex: Bool
//            if index == codes.count-1 {
//                isLastIndex = true
//            } else {
//                isLastIndex = false
//            }
//            Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(executeClosure), userInfo: ["code":code,"isLastIndex":isLastIndex], repeats: false)
//            serial.sendMessageToDevice("\(code.rawValue)\n")
//        }
    }

    @objc func executeClosure(timer: Timer) {
        let dictionary = timer.userInfo as? Dictionary<String, Any>
        
        let code = dictionary!["code"] as? RemoteCode
        print("\(code!) at \(DispatchTime.now().rawValue)")
        serial.sendMessageToDevice("\(code!.rawValue)\n")
            
        let isLastIndex = dictionary!["isLastIndex"] as? Bool
        if isLastIndex! {
            hideActivityIndicator()
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.text != nil) {
            sendAppleTVText(text: textField.text!)
        }

        textField.resignFirstResponder()    // dismiss the keyboard
        return true
    }
    
    // MARK: Activity Indicator
    
    func showActivityIndicator(){
        activityIndicator.startAnimating()
        activityAlertController.view.addSubview(activityIndicator)
        present(activityAlertController, animated: true, completion: nil)
    }
    
    func hideActivityIndicator() {
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: Button Press Actions
    
    // Newline character must be sent in order for Arduino to recognize the transmission is completed.
    @IBAction func tvOnButtonWasPressed(_ sender: Any) {
        serial.sendMessageToDevice("\(RemoteCode.MacroStartTV.rawValue)\n")
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.sendActions(for: UIControlEvents.valueChanged)
    }
    @IBAction func appleTvOnButtonWasPressed(_ sender: Any) {
        serial.sendMessageToDevice("\(RemoteCode.MacroStartAppleTV.rawValue)\n")
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.sendActions(for: UIControlEvents.valueChanged)
    }
    @IBAction func gameOnButtonWasPressed(_ sender: Any) {
        serial.sendMessageToDevice("\(RemoteCode.MacroStartGame.rawValue)\n")
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.sendActions(for: UIControlEvents.valueChanged)
    }

    @IBAction func tvSwitchButtonWasPressed(_ sender: Any) {
        serial.sendMessageToDevice("\(RemoteCode.MacroSwitchToTV.rawValue)\n")
    }
    @IBAction func appleTvSwitchButtonWasPressed(_ sender: Any) {
        serial.sendMessageToDevice("\(RemoteCode.MacroSwitchToAppleTV.rawValue)\n")
    }
    @IBAction func gameSwitchButtonWasPressed(_ sender: Any) {
        serial.sendMessageToDevice("\(RemoteCode.MacroSwitchToGame.rawValue)\n")
    }

    @IBAction func volumeDownButtonWasPressed(_ sender: Any) {
        serial.sendMessageToDevice("\(RemoteCode.DenonVolumeDown.rawValue)\n")
    }
    @IBAction func volumeUpButtonWasPressed(_ sender: Any) {
        serial.sendMessageToDevice("\(RemoteCode.DenonVolumeUp.rawValue)\n")
    }
    @IBAction func volumeMuteButtonWasPressed(_ sender: Any) {
        serial.sendMessageToDevice("\(RemoteCode.DenonMute.rawValue)\n")
    }

    @IBAction func channelUpButtonWasPressed(_ sender: Any) {
        // TODO: Fill this in
    }
    
    @IBAction func channelDownButtonWasPressed(_ sender: Any) {
        // TODO: Fill this in
    }
    
    @IBAction func refreshButtonWasPressed(_ sender: Any) {
        serial.disconnect()
        serial.stopScan()
        serial.startScan()
    }
    
    @IBAction func shutdownButtonWasPressed(_ sender: Any) {
        serial.sendMessageToDevice("\(RemoteCode.PanasonicPower.rawValue)\n")
    }
    
    @IBAction func menuButtonWasPressed(_ sender: Any) {
        serial.sendMessageToDevice("\(RemoteCode.AppleTVMenu.rawValue)\n")
    }
    
    @IBAction func touchpadButtonWasPressed(_ sender: Any) {
        serial.sendMessageToDevice("\(RemoteCode.AppleTVSelect.rawValue)\n")
    }
    @IBAction func playButtonWasPressed(_ sender: Any) {
        serial.sendMessageToDevice("\(RemoteCode.AppleTVPlay.rawValue)\n")
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0: // turn on
            controlState = .TurnOn
        case 1: // switch to
            controlState = .SwitchTo
        default:
            controlState = .TurnOn
        }
    }
    
    // MARK: Gesture recognizers
    
    @IBAction func volumeDownButtonWasLongPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(volumeDownButtonWasPressed(_:)), userInfo: self, repeats: true)
            volumeDownButton.isHighlighted = true
        } else if sender.state == .ended || sender.state == .cancelled {
            timer?.invalidate()
            timer = nil
            volumeDownButton.isHighlighted = false
        }
    }
    
    @IBAction func volumeUpButtonWasLongPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(volumeUpButtonWasPressed(_:)), userInfo: self, repeats: true)
            volumeUpButton.isHighlighted = true
        } else if sender.state == .ended || sender.state == .cancelled {
            timer?.invalidate()
            timer = nil
            volumeUpButton.isHighlighted = false
        }
    }

    @IBAction func touchpadWasSwipedRight(_ sender: UISwipeGestureRecognizer) {
        serial.sendMessageToDevice("\(RemoteCode.AppleTVRight.rawValue)\n")
    }
    
    @IBAction func touchpadWasSwipedLeft(_ sender: UISwipeGestureRecognizer) {
        serial.sendMessageToDevice("\(RemoteCode.AppleTVLeft.rawValue)\n")
    }
    
    @IBAction func touchpadWasSwipedDown(_ sender: UISwipeGestureRecognizer) {
        serial.sendMessageToDevice("\(RemoteCode.AppleTVDown.rawValue)\n")
    }
    
    @IBAction func touchpadWasSwipedUp(_ sender: UISwipeGestureRecognizer) {
        serial.sendMessageToDevice("\(RemoteCode.AppleTVUp.rawValue)\n")
    }
    
    @IBAction func testButton(_ sender: Any) {
        showActivityIndicator()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            self.hideActivityIndicator()
        })
        
//        var codes = AppleTVKeyboard.instance.remoteCodesForReset()
//
//        for code in codes {
//            serial.sendMessageToDevice("\(code.rawValue)\n")
//            usleep(100000)
//        }
//
//        codes = AppleTVKeyboard.instance.remoteCodesFor(string: "koji")
//
//        for code in codes {
//            serial.sendMessageToDevice("\(code.rawValue)\n")
//            usleep(100000)
//        }
    }
    
//    override func prefersStatusBarHidden() -> Bool {
//        return false
//    }
}

