//
//  MajiDevices.swift
//  LivingRoomRemote
//
//  Created by Koji Gardiner on 9/28/17.
//  Copyright © 2017 Koji Gardiner. All rights reserved.
//

import Foundation

// These values should match the code in "MajiDevicesDemo.ino" 
enum RemoteCode: Int {
    case AppleTVMenu = 1,
    AppleTVSelect,
    AppleTVUp,
    AppleTVDown,
    AppleTVLeft,
    AppleTVRight,
    AppleTVPlay,
    DenonPower,
    DenonDVDBluray,
    DenonGame,
    DenonMute,
    DenonTVAudio,
    DenonBluetooth,
    DenonVolumeUp,
    DenonVolumeDown,
    PanasonicPower,
    PanasonicInput,
    PanasonicCh1,
    PanasonicCh2,
    MacroStartAppleTV,
    MacroStartTV,
    MacroStartGame,
    MacroSwitchToAppleTV,
    MacroSwitchToTV,
    MacroSwitchToGame
}

enum ControlState: Int {
    case TurnOn = 0,
    SwitchTo
}
