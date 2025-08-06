import SwiftUI
import UserNotifications
import AVFoundation

// MARK: - Main Content View
struct ContentView: View {
    // MARK: - Properties
    @State private var currentTime = Date()
    @State private var showingAlarmSheet = false
    @State private var alarms: [Alarm] = []
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView
            mainContentView
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .sheet(isPresented: $showingAlarmSheet) {
            AlarmSheetView(alarms: $alarms)
        }
        .onAppear {
            requestNotificationPermission()
            setupNotificationHandler()
        }
    }
    
    // MARK: - View Components
    private var backgroundView: some View {
        Color.black
            .ignoresSafeArea()
    }
    
    private var mainContentView: some View {
        VStack(spacing: 30) {
            headerView
            Spacer()
            clockDisplayView
            Spacer()
            alarmsListView
            actionButtonsView
            Spacer()
            homeIndicatorView
        }
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            Text("APEX APPLICATIONS LLC")
                .font(.system(size: 24, weight: .medium, design: .monospaced))
                .foregroundColor(.neonGreen)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 100)
    }
    
    private var clockDisplayView: some View {
        VStack(spacing: 20) {
            timeDisplayView
            dateDisplayView
        }
    }
    
    private var timeDisplayView: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.neonGreen, lineWidth: 2)
            )
            .overlay(
                Text(mainTimeString)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.neonGreen)
                    .shadow(color: .neonGreen.opacity(0.8), radius: 10, x: 0, y: 0)
            )
            .frame(height: 120)
            .padding(.horizontal, 40)
    }
    
    private var dateDisplayView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neonGreen, lineWidth: 1.5)
            )
            .overlay(
                Text(dateString)
                    .font(.system(size: 18, weight: .medium, design: .monospaced))
                    .foregroundColor(.neonGreen)
            )
            .frame(height: 50)
            .padding(.horizontal, 60)
    }
    
    private var alarmsListView: some View {
        Group {
            if !alarms.isEmpty {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Your Alarms")
                        .font(.headline)
                        .foregroundColor(.neonGreen)
                        .padding(.leading, 20)
                    
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(alarms.indices, id: \.self) { index in
                                AlarmRowView(
                                    alarm: alarms[index],
                                    onDelete: {
                                        removeNotification(for: alarms[index])
                                        alarms.remove(at: index)
                                    }
                                )
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
            }
        }
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 15) {
            HStack(spacing: 20) {
                setAlarmButton
                clearAllButton
            }
            
            // Generate Icons Button
            Button(action: {
                generateIconsNow()
            }) {
                HStack {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Generate App Icons")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.neonGreen)
                        .shadow(color: .neonGreen.opacity(0.6), radius: 8, x: 0, y: 4)
                )
            }
        }
        .padding(.horizontal, 40)
    }
    
    private var setAlarmButton: some View {
        Button(action: {
            showingAlarmSheet = true
        }) {
            HStack {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                Text("Set Alarm")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.neonGreen)
                    .shadow(color: .neonGreen.opacity(0.6), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    private var clearAllButton: some View {
                            Button(action: {
                        removeAllNotifications()
                    }) {
                        HStack {
                            Image(systemName: "trash.circle")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Clear All")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red)
                                .shadow(color: .red.opacity(0.6), radius: 8, x: 0, y: 4)
                        )
                    }
    }
    
    private var homeIndicatorView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 134, height: 5)
            .cornerRadius(2.5)
            .padding(.bottom, 10)
    }
    
    // MARK: - Computed Properties
    private var mainTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss a"
        return formatter.string(from: currentTime)
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: currentTime)
    }
    
    // MARK: - Private Methods
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    private func setupNotificationHandler() {
        UNUserNotificationCenter.current().delegate = NotificationHandler.shared
    }
    
    private func removeNotification(for alarm: Alarm) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [alarm.id.uuidString])
        print("🔔 Removed notification for alarm: \(alarm.label)")
    }
    
    private func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("🔔 Removed all notifications")
    }
    
    private func generateIconsNow() {
        print("🎨 I-RIZE App Icon Instructions:")
        print("\n📱 HOW TO ADD ICONS TO XCODE:")
        print("1. Open Xcode")
        print("2. In Project Navigator, click 'Assets.xcassets'")
        print("3. Click 'AppIcon'")
        print("4. You need to create icon images manually:")
        print("\n   Required Icon Sizes:")
        print("   iPhone: 20x20, 29x29, 40x40, 60x60 (2x and 3x scales)")
        print("   iPad: 20x20, 29x29, 40x40, 76x76, 83.5x83.5")
        print("   App Store: 1024x1024")
        print("\n   Design Requirements:")
        print("   - Black background")
        print("   - 'I RIZE' text in neon green")
        print("   - Rising sun graphic with 7 rays")
        print("   - Rounded corners")
        print("\n5. Create icons using any image editor (Photoshop, Figma, etc.)")
        print("6. Drag PNG files to matching slots in Xcode")
        print("7. Clean Build Folder (Product → Clean Build Folder)")
        print("8. Build and run the app")
        print("\n💡 Tip: Use the AppIconGenerator.swift file to generate icons programmatically")
    }
}

// MARK: - Alarm Row View
struct AlarmRowView: View {
    let alarm: Alarm
    let onDelete: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neonGreen, lineWidth: 2)
                    .shadow(color: .neonGreen.opacity(0.6), radius: 6, x: 0, y: 0)
            )
            .overlay(
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(alarm.label)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(alarm.time, style: .time)
                            .font(.subheadline)
                            .foregroundColor(.neonGreen)
                    }
                    Spacer()
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .padding()
            )
            .frame(height: 60)
            .padding(.horizontal, 20)
    }
}

// MARK: - ElevenLabs Configuration
struct ElevenLabsConfig {
    static let apiKey = "sk_6b175092c8455ec2b6e5f180f8124cc289739c663ffd981b"
    static let baseURL = "https://api.elevenlabs.io/v1"
    static let textToSpeechEndpoint = "/text-to-speech"
    
    static let voiceIDs = [
        "voice1": "alMSnmMfBQWEfTP8MRcX",
        "voice2": "",
        "voice3": "",
        "voice4": "",
        "voice5": ""
    ]
    
    static let voiceSettings: [String: Any] = [
        "stability": 0.5,
        "similarity_boost": 0.75,
        "style": 0.0,
        "use_speaker_boost": true
    ]
}

// MARK: - ElevenLabs Service
final class ElevenLabsService {
    static let shared = ElevenLabsService()
    
    private init() {}
    
    func generateSpeech(text: String, voiceID: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: "\(ElevenLabsConfig.baseURL)\(ElevenLabsConfig.textToSpeechEndpoint)/\(voiceID)") else {
            print("Invalid URL for voice ID: \(voiceID)")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(ElevenLabsConfig.apiKey, forHTTPHeaderField: "xi-api-key")
        
        let requestBody: [String: Any] = [
            "text": text,
            "model_id": "eleven_monolingual_v1",
            "voice_settings": ElevenLabsConfig.voiceSettings
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("Error creating request body: \(error)")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.handleResponse(data: data, response: response, error: error, voiceID: voiceID, completion: completion)
            }
        }.resume()
    }
    
    private func handleResponse(data: Data?, response: URLResponse?, error: Error?, voiceID: String, completion: @escaping (Data?) -> Void) {
        if let error = error {
            print("ElevenLabs API Error: \(error)")
            completion(nil)
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid response type")
            completion(nil)
            return
        }
        
        switch httpResponse.statusCode {
        case 200:
            print("✅ Success - Audio data received: \(data?.count ?? 0) bytes")
            completion(data)
        case 401:
            print("❌ Unauthorized - Check your API key!")
            completion(nil)
        case 404:
            print("❌ Voice not found - Check voice ID: \(voiceID)")
            completion(nil)
        default:
            print("❌ API Error - Status code: \(httpResponse.statusCode)")
            completion(nil)
        }
    }
    
    func getAvailableVoices(completion: @escaping ([Voice]?) -> Void) {
        guard let url = URL(string: "\(ElevenLabsConfig.baseURL)/voices") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(ElevenLabsConfig.apiKey, forHTTPHeaderField: "xi-api-key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data, let voices = try? JSONDecoder().decode(VoiceResponse.self, from: data) {
                    completion(voices.voices)
                } else {
                    completion(nil)
                }
            }
        }.resume()
    }
}

// MARK: - Notification Handler
final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()
    private let elevenLabsService = ElevenLabsService.shared
    
    private override init() {
        super.init()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
        handleNotification(notification)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        handleNotification(response.notification)
        completionHandler()
    }
    
    private func handleNotification(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        guard let message = userInfo["message"] as? String,
              let voiceID = userInfo["voiceID"] as? String else { return }
        
        print("🔔 Alarm triggered! Playing voice for message: \(message)")
        print("🎵 Using voice ID: \(voiceID)")
        
        elevenLabsService.generateSpeech(text: message, voiceID: voiceID) { audioData in
            if let audioData = audioData {
                print("✅ ElevenLabs audio generated successfully")
                DispatchQueue.main.async {
                    self.playAlarmVoice(audioData)
                }
            } else {
                print("❌ Failed to generate ElevenLabs audio")
            }
        }
    }
    
    private func playAlarmVoice(_ audioData: Data) {
        do {
            print("🎵 Playing alarm voice...")
            
            #if os(iOS)
            try setupAudioSession()
            #endif
            
            let audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer.volume = 1.0
            audioPlayer.prepareToPlay()
            
            let success = audioPlayer.play()
            print("🎵 Alarm voice player started: \(success)")
            
            if success {
                print("✅ Alarm voice is now playing")
                monitorAudioPlayback(audioPlayer)
            } else {
                print("❌ Alarm voice player failed to start")
                try? playAlarmVoiceAlternative(audioData)
            }
            
        } catch {
            print("❌ Error playing alarm voice: \(error)")
        }
    }
    
    #if os(iOS)
    private func setupAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default, options: [.defaultToSpeaker])
        try audioSession.setActive(true)
        print("🔊 Audio session activated for alarm with speaker output")
        
        let currentVolume = audioSession.outputVolume
        print("📱 Device volume: \(currentVolume)")
        
        if currentVolume < 0.1 {
            print("⚠️ WARNING: Device volume is very low! Please turn up your device volume.")
        }
    }
    #endif
    
    private func monitorAudioPlayback(_ audioPlayer: AVAudioPlayer) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if audioPlayer.isPlaying {
                print("✅ Audio is still playing after 1 second")
            } else {
                print("❌ Audio stopped playing unexpectedly")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + audioPlayer.duration + 1) {
            print("🎵 Alarm voice playback finished")
        }
    }
    
    private func playAlarmVoiceAlternative(_ audioData: Data) throws {
        print("🎵 Trying alternative audio playback method...")
        
        #if os(iOS)
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default, options: [.defaultToSpeaker])
        try audioSession.setActive(true)
        print("🔊 Set audio to speaker output (alternative method)")
        #endif
        
        let audioPlayer = try AVAudioPlayer(data: audioData)
        audioPlayer.volume = 1.0
        audioPlayer.prepareToPlay()
        
        let success = audioPlayer.play()
        print("🎵 Alternative audio player started: \(success)")
        
        if success {
            print("✅ Alternative audio is now playing")
        } else {
            print("❌ Alternative audio player also failed")
        }
    }
}

// MARK: - Data Models
struct VoiceResponse: Codable {
    let voices: [Voice]
}

struct Voice: Codable, Identifiable {
    let id: String
    let name: String
    let category: String
    let description: String?
    let labels: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case id = "voice_id"
        case name, category, description, labels
    }
}

struct Alarm: Identifiable, Codable {
    let id: UUID
    var time: Date
    var isEnabled: Bool
    var label: String
    var repeatDays: [Int]
    
    init(time: Date, isEnabled: Bool, label: String, repeatDays: [Int]) {
        self.id = UUID()
        self.time = time
        self.isEnabled = isEnabled
        self.label = label
        self.repeatDays = repeatDays
    }
}

// MARK: - Extensions
extension Color {
    static let neonGreen = Color(red: 0.0, green: 1.0, blue: 0.0)
}

// MARK: - Alarm Sheet View
struct AlarmSheetView: View {
    @Binding var alarms: [Alarm]
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTime = Date()
    @State private var customAlarmMessages = ["", "", "", "", ""]
    @State private var customVoiceNames = ["Simeon", "Rachel", "Domi", "Bella", "Josh"]
    @State private var customVoiceIDs = ["alMSnmMfBQWEfTP8MRcX", "V33LkP9pVLdcjeB2y5Na", "AZnzlk1XvdvUeBnXmlld", "tQ4MEZFJOzsahSEEZtHK", "dPah2VEoifKnZT37774q"]
    @State private var selectedVoiceForMessage = 0
    @State private var showingConfiguration = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    titleView
                    timePickerSection
                    alarmSelectionSection
                    Spacer()
                    actionButtonsSection
                }
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .sheet(isPresented: $showingConfiguration) {
                SetAlarmView(alarms: $alarms)
            }
        }
    }
    
    private var titleView: some View {
        Text("Set Alarm")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.top, 20)
    }
    
    private var timePickerSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Alarm Time")
                .font(.headline)
                .foregroundColor(.neonGreen)
                .padding(.leading, 5)
            
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.neonGreen, lineWidth: 2)
                        .shadow(color: .neonGreen.opacity(0.6), radius: 8, x: 0, y: 0)
                )
                .overlay(
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        #if os(iOS)
                        .datePickerStyle(.wheel)
                        #endif
                        .labelsHidden()
                        .colorScheme(.dark)
                        .padding()
                )
                .frame(height: 200)
        }
        .padding(.horizontal, 20)
    }
    
    private var alarmSelectionSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Select Alarm")
                .font(.headline)
                .foregroundColor(.neonGreen)
                .padding(.leading, 5)
            
            ForEach(0..<3, id: \.self) { index in
                Button(action: {
                    createAlarm(for: index)
                }) {
                    AlarmSelectionRow(title: "Alarm \(index + 1)")
                }
                .buttonStyle(PlainButtonStyle())
                .frame(height: 50)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 15) {
            Button("Configure Voice & Message") {
                showingConfiguration = true
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private func createAlarm(for index: Int) {
        let alarmMessage = customAlarmMessages[index].isEmpty ? "Alarm \(index + 1)" : customAlarmMessages[index]
        let newAlarm = Alarm(time: selectedTime, isEnabled: true, label: alarmMessage, repeatDays: [])
        alarms.append(newAlarm)
        scheduleNotification(for: newAlarm)
        dismiss()
    }
    
    private func scheduleNotification(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "I-RIZE Alarm"
        content.body = alarm.label
        content.sound = .default
        
        let alarmData: [String: Any] = [
            "message": alarm.label,
            "voiceID": customVoiceIDs[selectedVoiceForMessage],
            "voiceName": customVoiceNames[selectedVoiceForMessage]
        ]
        content.userInfo = alarmData
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: alarm.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
        print("🔔 Scheduled alarm for \(alarm.label) with voice: \(customVoiceNames[selectedVoiceForMessage])")
    }
}

// MARK: - Supporting Views
struct AlarmSelectionRow: View {
    let title: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neonGreen, lineWidth: 2)
                    .shadow(color: .neonGreen.opacity(0.6), radius: 6, x: 0, y: 0)
            )
            .overlay(
                HStack {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.neonGreen)
                }
                .padding()
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.neonGreen)
                    .shadow(color: .neonGreen.opacity(0.6), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Set Alarm View
struct SetAlarmView: View {
    @Binding var alarms: [Alarm]
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTime = Date()
    @State private var customAlarmMessages = ["", "", ""]
    @State private var customVoiceNames = ["Simeon", "Rachel", "Domi"]
    @State private var customVoiceIDs = ["alMSnmMfBQWEfTP8MRcX", "V33LkP9pVLdcjeB2y5Na", "AZnzlk1XvdvUeBnXmlld"]
    @State private var showingMessagePicker = false
    @State private var selectedMessageIndex = 0
    @State private var selectedVoiceForMessage = 0
    
    private let predefinedMessages = [
        "Wake up! It's a new day and a new chance to take control. You've got breath in your lungs, strength in your body, and fire in your spirit. No more snoozing through your potential — get up and show life exactly who you are. You're built for progress, made for impact, and today is yours to dominate. Let's move. Let's rise. Let's win.",
        "YOUR PARAGRAPH 2 HERE - Write your custom alarm message paragraph here",
        "YOUR PARAGRAPH 3 HERE - Write your custom alarm message paragraph here"
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                titleView
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        alarmMessagesSection
                        voiceSelectionSection
                    }
                    .padding(.horizontal, 20)
                }
                actionButtonsView
            }
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
        .sheet(isPresented: $showingMessagePicker) {
            MessagePickerView(
                selectedMessage: $customAlarmMessages[selectedMessageIndex],
                predefinedMessages: predefinedMessages
            )
        }
    }
    
    private var titleView: some View {
        Text("Set Alarm")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.top, 20)
            .padding(.bottom, 20)
    }
    
    private var alarmMessagesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose Alarm Messages")
                .font(.headline)
                .foregroundColor(.neonGreen)
                .padding(.leading, 5)
            
            VStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Button(action: {
                        showMessagePicker(for: index)
                    }) {
                        MessageSelectionRow(
                            message: customAlarmMessages[index],
                            placeholder: "Choose message \(index + 1)"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(height: 50)
                }
            }
        }
    }
    
    private var voiceSelectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select Voice for Each Message")
                .font(.headline)
                .foregroundColor(.neonGreen)
                .padding(.leading, 5)
            
            VStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Button(action: {
                        selectVoiceForMessage(index: index)
                    }) {
                        VoiceSelectionRow(
                            voiceName: customVoiceNames[index],
                            message: customAlarmMessages[index],
                            isSelected: selectedVoiceForMessage == index
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(height: 60)
                }
            }
        }
    }
    
    private var actionButtonsView: some View {
        HStack(spacing: 15) {
            Button("Set") {
                setVoiceAndMessage()
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Button("Close") {
                dismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private func showMessagePicker(for index: Int) {
        selectedMessageIndex = index
        showingMessagePicker = true
    }
    
    private func selectVoiceForMessage(index: Int) {
        selectedVoiceForMessage = index
        print("🎤 Selected voice: \(customVoiceNames[index]) for message")
    }
    
    private func setVoiceAndMessage() {
        let hasSelectedMessage = customAlarmMessages.contains { !$0.isEmpty }
        
        if hasSelectedMessage {
            let selectedMessage = customAlarmMessages.first { !$0.isEmpty } ?? "Alarm"
            let selectedVoiceName = customVoiceNames[selectedVoiceForMessage]
            let selectedVoiceID = customVoiceIDs[selectedVoiceForMessage]
            
            print("🎤 Voice and message settings configured:")
            print("📝 Message: \(selectedMessage)")
            print("🎵 Voice: \(selectedVoiceName)")
            print("🔑 Voice ID: \(selectedVoiceID)")
            
            dismiss()
        } else {
            print("⚠️ Please select a message before setting the voice and message")
        }
    }
}

// MARK: - Supporting Row Views
struct MessageSelectionRow: View {
    let message: String
    let placeholder: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neonGreen, lineWidth: 2)
                    .shadow(color: .neonGreen.opacity(0.6), radius: 6, x: 0, y: 0)
            )
            .overlay(
                HStack {
                    Text(message.isEmpty ? placeholder : message)
                        .foregroundColor(message.isEmpty ? .gray : .white)
                        .font(.system(size: 16, weight: .medium))
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.neonGreen)
                }
                .padding()
            )
    }
}

struct VoiceSelectionRow: View {
    let voiceName: String
    let message: String
    let isSelected: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neonGreen, lineWidth: 2)
                    .shadow(color: .neonGreen.opacity(0.6), radius: 6, x: 0, y: 0)
            )
            .overlay(
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(voiceName)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                        if !message.isEmpty {
                            Text(message)
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.neonGreen)
                            .font(.title2)
                    }
                }
                .padding()
            )
    }
}

// MARK: - Message Picker View
struct MessagePickerView: View {
    @Binding var selectedMessage: String
    let predefinedMessages: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Text("Choose Alarm Message")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(predefinedMessages, id: \.self) { message in
                                Button(action: {
                                    selectedMessage = message
                                    dismiss()
                                }) {
                                    MessagePickerRow(
                                        message: message,
                                        isSelected: selectedMessage == message
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Select Message")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.neonGreen)
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.neonGreen)
                }
                #endif
            }
        }
    }
}

struct MessagePickerRow: View {
    let message: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text(message)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .font(.system(size: 16, weight: .medium))
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.neonGreen)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.neonGreen.opacity(0.2) : Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.neonGreen : Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
#Preview {
    ContentView()
} 
