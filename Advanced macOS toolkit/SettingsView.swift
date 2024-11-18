import SwiftUI
struct SettingsView : View {
    @State private var useVO = Settings.useVO
    @State private var UseNotificationSystem = Settings.useNotifications
    @State private var speechRate = Settings.utterance.rate
    @State private var speechPitch = Settings.utterance.pitchMultiplier
    @State private var speechVolume = Settings.utterance.volume
    @State private var showFileImporter = false
    @State private var wrongFile = false
    @State private var errorMessage = ""
    @State private var useCustomNotificationSounds = false
    var body: some View {
        Section("General settings") {
            HStack {
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
                        Button("Genericc notification Sound") {
                            showFileImporter.toggle()
                        }
                    }
                }
            }
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.wav, .aiff, .mp3]) { error in
            do {
                let fileString = try error.get().absoluteString
                try Settings.copyToBundle(fileString)
            } catch(let err) {
                errorMessage = err.localizedDescription
            }
        }
        .alert("File import error", isPresented: $wrongFile) {
            Button("OK") {
                
            }
        } message: {
            Text("something went wrong during the process. Error message: \(errorMessage)")
        }
    }
}
