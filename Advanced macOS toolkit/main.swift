//
//  main.swift
//  Advanced macOS toolkit
//
//  Created by Gruia Chiscop on 11/20/24.
//

import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
