//
//  utility.swift
//  CuckooClock
//
//  Created by Gruia Chiscop on 9/1/24.
//

import Cocoa
import UserNotifications
import AVFoundation
import Carbon

class Settings {
    static let utterance = AVSpeechUtterance()
    static var voice = AVSpeechSynthesisVoice(language: "en-US")
    static let synthesizer = AVSpeechSynthesizer()
    static var useNotifications = false
    static var useVO = false
    static var intervals = [Double()]
    
    static func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = Self.utterance.rate
        utterance.pitchMultiplier = Self.utterance.pitchMultiplier
        utterance.volume = Self.utterance.volume
        utterance.voice = Self.voice
        Self.utterance.voice = Self.voice
        Self.synthesizer.speak(utterance)
    }
    
    static func setupEspeakIfInstalled() {
        if let voice = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.name == "ESpeak" && $0.language == "en-US"}) {
            let selectedVoice = AVSpeechSynthesisVoice(identifier: voice.identifier)
            Self.voice = selectedVoice
            Self.utterance.voice = selectedVoice
            let alert = NSAlert()
            alert.messageText = "ESpeak found"
            alert.informativeText = "eSpeak found installed on your system, so the app will use it to announce the time. You can switch to another voice in the settings menu"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        } else {
            //fallback to probably samantha
            Self.utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
    }
    
    static func isTrusted(ask:Bool) -> Bool {
        let prompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options = [prompt: ask]
        return AXIsProcessTrustedWithOptions(options as CFDictionary?)
    }
    
    static func requestNotificationAccess() async -> Bool{
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            Self.useNotifications = true
            return true
        } catch {
            Self.useNotifications = false
            return false
        }
    }
    
    static func copyToBundle(_ file: String) throws {
        let filemanager = FileManager.default
        let bundlePath = Bundle.main.bundlePath
        try filemanager.copyItem(atPath: file, toPath: bundlePath)
    }
    static func save() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(Self.voice?.identifier, forKey: "voice")
        userDefaults.set(Self.utterance.rate, forKey: "rate")
        userDefaults.set(Self.utterance.pitchMultiplier, forKey: "pitch")
        userDefaults.set(Self.utterance.volume, forKey: "volume")
        userDefaults.set(Self.useNotifications, forKey: "useNotifications")
        userDefaults.set(intervals, forKey: "intervals")
    }
    static func load() {
        let defaults = UserDefaults.standard
        if let intervals = defaults.array(forKey: "intervals") as? [Double] {
            Self.intervals = intervals
        } else {
            Self.intervals = []
        }
        if let pitch = defaults.object(forKey: "pitch") as? Float {
            Self.utterance.pitchMultiplier = pitch
        } else {
            Self.utterance.pitchMultiplier = 1.0
        }
        if let volume = defaults.object(forKey: "volume") as? Float {
            Self.utterance.volume = volume
        } else {
            Self.utterance.volume = 0.5
        }
        if let notifications = defaults.object(forKey: "useNotifications") as? Bool {
            Self.useNotifications = notifications
        } else {
            Self.useNotifications = false
        }
        if let voiceid = defaults.object(forKey: "voice") as? String {
            Self.voice = AVSpeechSynthesisVoice(identifier: voiceid)
        } else {
            Self.setupEspeakIfInstalled()
        }
        if let rate = defaults.object(forKey: "rate") as? Float {
            Self.utterance.rate = rate
        } else {
            Self.utterance.rate = 0.5
        }
    }
    static func sendNotification(title: String, message: String, sound: String = "default", instant: Bool = false) {
        if Self.useNotifications { //we prefer to use this instead of playing a sound
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = message
            if sound.lowercased() == "default" {
                content.sound = .default
            } else {
                content.sound = .init(named: UNNotificationSoundName(sound))
            }
            var dateComponents = DateComponents()
            dateComponents.minute = 0
            if !instant {
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    let request = UNNotificationRequest(identifier: title, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error in adding the notification request to the center \(error.localizedDescription)")
                    }
                }
            } else {
                let request = UNNotificationRequest(identifier: title, content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error in adding the notification request to the center \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
