//
//  AppleTVKeyboard.swift
//  LivingRoomRemote
//
//  Created by Koji Gardiner on 9/28/17.
//  Copyright © 2017 Koji Gardiner. All rights reserved.
//

import Foundation
import UIKit

class AppleTVKeyboard {
    static let instance = AppleTVKeyboard()
    
    let keyboardChars = "abcdefghijklmnopqrstuvwxyz1234567890 */**_" // use space for space, slash for delete, and underscore for clear
    let keyboardCols = 6
    let keyboardRows = 7
    let lastRowCols = 3
    let uiOverheadRows = 2
    private(set) public var keyboard = [Character:[Int]]()
    
    private init() {
        var count = 0
        for row in 0..<keyboardRows {
            for col in 0..<keyboardCols {
                let index = keyboardChars.index(keyboardChars.startIndex, offsetBy: count)
                //print(keyboardChars[index])
                keyboard[keyboardChars[index]] = [col, row]
                count = count + 1
            }
        }
//        for i in 0..<keyboardChars.characters.count {
//            let index = keyboardChars.index(keyboardChars.startIndex, offsetBy: i)
//            let currentChar = keyboardChars[index]
//            print("\(currentChar): \(keyboard[currentChar] ?? [-1,-1])")
//        }
        
        print("AppleTVKeyboard singleton initialized")
    }
    
    // Reset cursor at "0" on the keyboard
    func remoteCodesForReset() -> [RemoteCode] {
        var remoteCodes = [RemoteCode]()
        for _ in 0..<keyboardRows + uiOverheadRows - 1 {
            remoteCodes.append(.AppleTVDown)
        }
        for _ in 0..<keyboardCols - 1 {
            remoteCodes.append(.AppleTVLeft)
        }
//        for _ in 0..<keyboardRows - 1 {
//            remoteCodes.append(.AppleTVUp)
//        }
        for _ in 0..<lastRowCols - 1 {
            remoteCodes.append(.AppleTVRight)
        }
        remoteCodes.append(.AppleTVUp)
        
        return remoteCodes
    }
    
    func remoteCodesFor(string: String) -> [RemoteCode] {
        var lowercaseString = string.lowercased()
        
        var remoteCodes = [RemoteCode]()
        
        remoteCodes.append(contentsOf: remoteCodesForReset())   // add the reset to "0" codes first
        var lastCoord = keyboard["0"] // coordinates for "0"
        if (lastCoord == nil) {
            print("ERROR: Keyboard '0' not found")
        }
        
        for charIndex in 0..<lowercaseString.characters.count {
            let index = lowercaseString.index(lowercaseString.startIndex, offsetBy: charIndex)
            let currentChar = lowercaseString[index]
            
            if var currentCharCoord = keyboard[currentChar] {// find the coordinate for the corresponding character. wrap this in an if let in case the character is not supported

                var deltaCoord = [0,0]
                deltaCoord[0] = currentCharCoord[0] - lastCoord![0]
                deltaCoord[1] = currentCharCoord[1] - lastCoord![1]
                
                // First do the left/right move, then the up/down. This ensures the last row of Space/Delete/Clear is handled properly.
                if deltaCoord[0] < 0 {  // if col delta is negative, move left
                    for _ in 0..<deltaCoord[0] * -1 { // invert the negative value for the loop
                        remoteCodes.append(.AppleTVLeft)
                    }
                } else if deltaCoord[0] > 0 {   // otherwise move right
                    for _ in 0..<deltaCoord[0] {
                        remoteCodes.append(.AppleTVRight)
                    }
                }
                
                if deltaCoord[1] < 0 {  // if the row delta is negative, move up
                    for _ in 0..<deltaCoord[1] * -1 { // invert the negative value for the loop
                        remoteCodes.append(.AppleTVUp)
                    }
                } else if deltaCoord[1] > 0 {   // otherwise move down
                    for _ in 0..<deltaCoord[1] {
                        remoteCodes.append(.AppleTVDown)
                    }
                }
                
                remoteCodes.append(.AppleTVSelect)  // select the character
                
                // If on the last row we need to treat this separately due to the SPACE/DELETE/CLEAR keys. move up one row and explicitly give a coordinate for 5/7/0
                if currentChar == " " {         // space
                    remoteCodes.append(.AppleTVUp)
                    currentCharCoord = keyboard["5"]!
                } else if currentChar == "/" {  // delete
                    remoteCodes.append(.AppleTVUp)
                    currentCharCoord = keyboard["7"]!
                } else if currentChar == "_" {  // clear
                    remoteCodes.append(.AppleTVUp)
                    currentCharCoord = keyboard["0"]!
                }
                
                lastCoord = currentCharCoord // update the current coordinates
            }
        }
        
        return remoteCodes
    }
}
