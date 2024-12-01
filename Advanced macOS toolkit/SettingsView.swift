import SwiftUI

struct SettingsView: View {
    @State private var useVO = Settings.useVO
    @State private var UseNotificationSystem = Settings.useNotifications
    @State private var speechRate = Settings.utterance.rate
    @State private var speechPitch = Settings.utterance.pitchMultiplier
    @State private var speechVolume = Settings.utterance.volume
    @State private var showFileImporter = false
    @State private var wrongFile = false
    @State private var errorMessage = ""
    @State private var useCustomNotificationSounds = false
    @State private var voiceName = Settings.voice?.name
    @State private var voicelanguage = Settings.voice?.language
    @State private var quietHoursStart = 0
    @State private var quietHoursEnd = 0
    @State private var timeInterval = 30
    let allVoices = Settings.getAllVoices()

    var body: some View {
        NavigationStack {
            Form {
                Section("General settings") {
                    VStack(alignment: .leading) {
                        Text("Here you can change the app settings")
                        Toggle("Use VoiceOver", isOn: $useVO)
                            .toggleStyle(.checkbox)
                        Toggle("Use notifications", isOn: $UseNotificationSystem)
                            .toggleStyle(.checkbox)
                        if !UseNotificationSystem {
                            Button("Cuckoo sound") { showFileImporter.toggle() }
                        } else {
                            Toggle("Use custom notification sounds", isOn: $useCustomNotificationSounds)
                                .toggleStyle(.checkbox)
                            if useCustomNotificationSounds {
                                Button("Generic notification Sound") {
                                    showFileImporter.toggle()
                                }
                            }
                        }
                    }
                }
                
                Section("Speech settings") {
                    VStack(alignment: .leading) {
                        Picker("Language", selection: $voicelanguage) {
                            ForEach(Array(allVoices.keys), id: \.self) { key in
                                Text(key).tag(key)
                            }
                        }
                        if let selectedLanguage = voicelanguage,
                           let voices = allVoices[selectedLanguage] {
                            Picker("Voice", selection: $voiceName) {
                                ForEach(voices, id: \.self) { voice in
                                    Text(voice).tag(voice)
                                }
                            }
                            Slider(value: $speechRate, in: 0.0...1.0, step: 0.1) {
                                Text("Pitch rate")
                            }
                            Slider(value: $speechPitch, in: 0.0...1.0, step: 0.1) {
                                Text("Pitch")
                            }
                        }
                    }
                }
                
                Section("Timer settings") {
                    VStack(alignment: .leading) {
                        Text("Quiet hours")
                        Picker("From", selection: $quietHoursStart) {
                            ForEach(0...23, id: \.self) {
                                Text("\($0)").tag($0)
                            }
                        }
                        Picker("to", selection: $quietHoursEnd) {
                            ForEach(0...23, id: \.self) {
                                Text("\($0)").tag($0)
                            }
                        }
                        Picker("Timer interval", selection: $timeInterval) {
                            ForEach([5, 10, 15, 30, 45, 60], id: \.self) {
                                Text("\($0) minutes").tag($0)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Toolkit settings")
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.wav, .aiff, .mp3]) { result in
            do {
                let fileString = try result.get().absoluteString
                try Settings.copyToBundle(fileString)
            } catch {
                errorMessage = error.localizedDescription
                wrongFile = true
            }
        }
        .alert("File import error", isPresented: $wrongFile) {
            Button("OK") {}
        } message: {
            Text("Something went wrong during the process. Error message: \(errorMessage)")
        }
        .onDisappear {
            //Settings.
        }
    }
}
