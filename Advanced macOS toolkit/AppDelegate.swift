//
//  AppDelegate.swift
//  CuckooClock
//
//  Created by Gruia Chiscop on 9/1/24.
//

import Cocoa
import ServiceManagement
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var window: NSWindow!
    @IBOutlet weak var mainWindow: NSWindow!
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        //Settings.speak("started")
        //print(Settings.utterance.rate, Settings.utterance.volume, Settings.utterance.pitchMultiplier)
        Settings.load()
        NSSound(contentsOf: Bundle.main.url(forResource: "tick", withExtension: "wav")!, byReference: true)?.play()
        Settings.speak("Ready")
        if let button = statusItem.button {
            button.title = "Cuckoo Clock"
            button.action = #selector(clicked(_:))
        } else { print("the button is nil") }
        do {
            try SMAppService.mainApp.register()
        } catch {
            print("Could not register the app")
        }
        NSApp.setActivationPolicy(.accessory)
        if !Settings.useNotifications {
            let alert = NSAlert()
            alert.messageText = "Allow notifications"
            alert.informativeText = "This app needs to send you notifications to announce the clock"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Allow")
            alert.runModal()
        Task {
                await Settings.requestNotificationAccess()
            
            }
        }
        Settings.speak("Welcome!")
        Settings.sendNotification(title: "Welcome to the most powerfull macOS toolkit", message: "This is one of the most powerfull macOS toolkit, with great features designed especially for blind users.", sound: "tick.wav", instant: true)
            }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        Settings.save()

    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    @objc func clicked(_ sender: Any) {
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 480), styleMask: [.fullScreen, .titled, .closable, .miniaturizable, .resizable, .fullScreen], backing: .buffered, defer: false)
        NSApplication.shared.setActivationPolicy(.regular)
        window.title = "Toolkit settings"
        window.makeKeyAndOrderFront(nil)
        let hostingView = NSHostingView(rootView: SettingsView())
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        window.contentView?.addSubview(hostingView)

        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: window.contentView!.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: window.contentView!.bottomAnchor),
        ])
    }

}

