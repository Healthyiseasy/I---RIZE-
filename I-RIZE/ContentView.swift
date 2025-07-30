import SwiftUI
import UserNotifications
import AVFoundation

struct ContentView: View {
    @State private var currentTime = Date()
    @State private var showingAlarmSheet = false
    @State private var alarms: [Alarm] = []
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Status bar area
                HStack {
                    Spacer()
                    Text("APEX APPLICATIONS LLC")
                        .font(.system(size: 24, weight: .medium, design: .monospaced))
                        .foregroundColor(.neonGreen)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 100)
                
                Spacer()
                
                // Main clock display
                VStack(spacing: 20) {
                    // Time display
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
                    
                    // Date display
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
                
                Spacer()
                
                // Alarms list
                if !alarms.isEmpty {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Your Alarms")
                            .font(.headline)
                            .foregroundColor(.neonGreen)
                            .padding(.leading, 20)
                        
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(alarms.indices, id: \.self) { index in
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
                                                    Text(alarms[index].label)
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                    Text(alarms[index].time, style: .time)
                                                        .font(.subheadline)
                                                        .foregroundColor(.neonGreen)
                                                }
                                                Spacer()
                                                Button(action: {
                                                    alarms.remove(at: index)
                                                }) {
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
                        }
                        .frame(maxHeight: 200)
                    }
                }
                
                // Action buttons
                HStack(spacing: 20) {
                    // Set Alarm button
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
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Home indicator
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 134, height: 5)
                    .cornerRadius(2.5)
                    .padding(.bottom, 10)
            }
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
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter.string(from: currentTime)
    }
    
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
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    private func setupNotificationHandler() {
        UNUserNotificationCenter.current().delegate = NotificationHandler.shared
    }
}

// MARK: - ElevenLabs API Configuration
// Add your ElevenLabs API key and voice IDs here
struct ElevenLabsConfig {
    // Replace with your actual ElevenLabs API key
    static let apiKey = "sk_6b175092c8455ec2b6e5f180f8124cc289739c663ffd981b" // Add your API key here
    
    // Popular ElevenLabs voice IDs - replace with your actual voice IDs
    static let voiceIDs = [
        "voice1": "alMSnmMfBQWEfTP8MRcX", ///simeon
        "voice2": "", // 
        "voice3": "", //
        "voice4": "", // 
        "voice5": ""  // 
    ]
    
    // ElevenLabs API endpoints
    static let baseURL = "https://api.elevenlabs.io/v1"
    static let textToSpeechEndpoint = "/text-to-speech"
    
    // Voice settings
    static let voiceSettings: [String: Any] = [
        "stability": 0.5,
        "similarity_boost": 0.75,
        "style": 0.0,
        "use_speaker_boost": true
    ]
}

// MARK: - ElevenLabs API Service
class ElevenLabsService {
    static let shared = ElevenLabsService()
    
    init() {}
    
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
            "voice_settings": ElevenLabsConfig.voiceSettings as [String: Any]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("Error creating request body: \(error)")
            completion(nil)
            return
        }
        
        print("Making request to ElevenLabs API...")
        print("URL: \(url)")
        print("API Key: \(ElevenLabsConfig.apiKey.prefix(10))...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("ElevenLabs API Error: \(error)")
                    completion(nil)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        print("❌ Unauthorized - Check your API key!")
                        print("Current API key: \(ElevenLabsConfig.apiKey)")
                        print("🔑 Please verify your API key at https://elevenlabs.io/account")
                        completion(nil)
                        return
                    } else if httpResponse.statusCode == 404 {
                        print("❌ Voice not found - Check voice ID: \(voiceID)")
                        completion(nil)
                        return
                    } else if httpResponse.statusCode != 200 {
                        print("❌ API Error - Status code: \(httpResponse.statusCode)")
                        completion(nil)
                        return
                    } else {
                        print("✅ Success - Audio data received: \(data?.count ?? 0) bytes")
                        
                        // Check if data looks like valid audio
                        if let data = data {
                            if data.count < 100 {
                                print("⚠️ Warning: Audio data seems too small (\(data.count) bytes)")
                            } else {
                                print("✅ Audio data size looks good (\(data.count) bytes)")
                            }
                        }
                    }
                }
                
                completion(data)
            }
        }.resume()
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

// MARK: - Notification Handler for Voice Playback
class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()
    private let elevenLabsService = ElevenLabsService()
    
    override init() {
        super.init()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
        
        // Play ElevenLabs voice if available
        let userInfo = notification.request.content.userInfo
        if let message = userInfo["message"] as? String,
           let voiceID = userInfo["voiceID"] as? String {
            
            print("🔔 Alarm triggered! Playing voice for message: \(message)")
            print("🎵 Using voice ID: \(voiceID)")
            
            // Generate and play the voice
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
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification when app is in background and user taps on it
        let userInfo = response.notification.request.content.userInfo
        if let message = userInfo["message"] as? String,
           let voiceID = userInfo["voiceID"] as? String {
            
            print("🔔 Background alarm triggered! Playing voice for message: \(message)")
            print("🎵 Using voice ID: \(voiceID)")
            
            // Generate and play the voice
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
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive notification: UNNotification) {
        // Handle notification when app is in background (iOS 10+)
        let userInfo = notification.request.content.userInfo
        if let message = userInfo["message"] as? String,
           let voiceID = userInfo["voiceID"] as? String {
            
            print("🔔 Background notification received! Playing voice for message: \(message)")
            print("🎵 Using voice ID: \(voiceID)")
            
            // Generate and play the voice
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
    }
    
    private func playAlarmVoice(_ audioData: Data) {
        do {
            print("🎵 Playing alarm voice...")
            
            #if os(iOS)
            // Set up audio session for alarm playback with simpler, more compatible settings
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
            print("🔊 Audio session activated for alarm with speaker output")
            
            // Check device volume
            let currentVolume = audioSession.outputVolume
            print("📱 Device volume: \(currentVolume)")
            
            if currentVolume < 0.1 {
                print("⚠️ WARNING: Device volume is very low! Please turn up your device volume.")
            }
            #endif
            
            let audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer.volume = 1.0
            audioPlayer.prepareToPlay()
            
            let success = audioPlayer.play()
            print("🎵 Alarm voice player started: \(success)")
            print("🎵 Audio duration: \(audioPlayer.duration) seconds")
            
            if success {
                print("✅ Alarm voice is now playing")
                
                // Keep the audio player alive and check if it's actually playing
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
            } else {
                print("❌ Alarm voice player failed to start")
                
                // Try alternative method
                print("🔄 Trying alternative playback method...")
                try? self.playAlarmVoiceAlternative(audioData)
            }
            
        } catch {
            print("❌ Error playing alarm voice: \(error)")
            print("Error details: \(error.localizedDescription)")
        }
    }
    
    private func playAlarmVoiceAlternative(_ audioData: Data) throws {
        print("🎵 Trying alternative audio playback method...")
        
        #if os(iOS)
        // Force audio session to speaker output with simplified settings
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

// MARK: - ElevenLabs Data Models
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

// Custom color extension
extension Color {
    static let neonGreen = Color(red: 0.0, green: 1.0, blue: 0.0)
}

// Alarm model
struct Alarm: Identifiable, Codable {
    let id: UUID
    var time: Date
    var isEnabled: Bool
    var label: String
    var repeatDays: [Int] // 0 = Sunday, 1 = Monday, etc.
    
    init(time: Date, isEnabled: Bool, label: String, repeatDays: [Int]) {
        self.id = UUID()
        self.time = time
        self.isEnabled = isEnabled
        self.label = label
        self.repeatDays = repeatDays
    }
}

// Alarm sheet view
struct AlarmSheetView: View {
    @Binding var alarms: [Alarm]
    @Environment(\.dismiss) var dismiss
    @State private var selectedTime = Date()
    @State private var customAlarmMessages: [String] = ["", "", "", "", ""]
    @State private var customVoiceNames: [String] = ["Simeon", "Rachel", "Domi", "Bella", "Josh"]
    @State private var customVoiceIDs: [String] = ["alMSnmMfBQWEfTP8MRcX", "V33LkP9pVLdcjeB2y5Na", "AZnzlk1XvdvUeBnXmlld", "tQ4MEZFJOzsahSEEZtHK", "dPah2VEoifKnZT37774q"]
    @State private var selectedVoiceForMessage = 0
    @State private var showingConfiguration = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Title
                    Text("Set Alarm")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    // Time Picker Section
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
                                Group {
                                    #if os(iOS)
                                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.wheel)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                        .padding()
                                    #else
                                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                        .padding()
                                    #endif
                                }
                            )
                            .frame(height: 200)
                    }
                    .padding(.horizontal, 20)
                    
                    // Alarm Selection Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Select Alarm")
                            .font(.headline)
                            .foregroundColor(.neonGreen)
                            .padding(.leading, 5)
                        ForEach(0..<3, id: \.self) { index in
                            Button(action: {
                                // Set the alarm directly when button is pressed
                                let alarmMessage = customAlarmMessages[index].isEmpty ? "Alarm \(index + 1)" : customAlarmMessages[index]
                                let newAlarm = Alarm(time: selectedTime, isEnabled: true, label: alarmMessage, repeatDays: [])
                                alarms.append(newAlarm)
                                scheduleNotification(for: newAlarm)
                                dismiss()
                            }) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.neonGreen, lineWidth: 2)
                                            .shadow(color: .neonGreen.opacity(0.6), radius: 6, x: 0, y: 0)
                                    )
                                    .overlay(
                                        HStack {
                                            Text("Alarm \(index + 1)")
                                                .foregroundColor(.white)
                                                .font(.system(size: 16, weight: .medium))
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.neonGreen)
                                        }
                                        .padding()
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(height: 50)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Configure and Cancel Buttons
                    VStack(spacing: 15) {
                        Button(action: {
                            showingConfiguration = true
                        }) {
                            Text("Configure Voice & Message")
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
                        }
                        .padding(.horizontal, 20)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
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
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                }
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
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
            .sheet(isPresented: $showingConfiguration) {
                SetAlarmView(alarms: $alarms)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func scheduleNotification(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "I-RIZE Alarm"
        content.body = alarm.label
        content.sound = .default
        
        // Store alarm data for voice playback with selected voice
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

// Set Alarm view with full functionality
struct SetAlarmView: View {
    @Binding var alarms: [Alarm]
    @Environment(\.dismiss) var dismiss
    @State private var selectedTime = Date()
    @State private var customAlarmMessages: [String] = ["", "", ""]
    @State private var customVoiceNames: [String] = ["Simeon", "Rachel", "Domi"]
    @State private var customVoiceIDs: [String] = ["alMSnmMfBQWEfTP8MRcX", "V33LkP9pVLdcjeB2y5Na", "AZnzlk1XvdvUeBnXmlld"]
    @State private var showingMessagePicker = false
    @State private var selectedMessageIndex = 0
    @State private var selectedVoiceForMessage = 0 // Track which voice is selected
    
    // Custom alarm paragraphs - ADD YOUR PARAGRAPHS HERE
    let predefinedMessages = [
        "Wake up! It’s a new day and a new chance to take control. You’ve got breath in your lungs, strength in your body, and fire in your spirit. No more snoozing through your potential — get up and show life exactly who you are. You’re built for progress, made for impact, and today is yours to dominate. Let’s move. Let’s rise. Let’s win.",
        "YOUR PARAGRAPH 2 HERE - Write your custom alarm message paragraph here", 
        "YOUR PARAGRAPH 3 HERE - Write your custom alarm message paragraph here"
    ]

    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Title
                Text("Set Alarm")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
            
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Predefined Alarm Messages Section
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
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.black)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.neonGreen, lineWidth: 2)
                                                    .shadow(color: .neonGreen.opacity(0.6), radius: 6, x: 0, y: 0)
                                            )
                                            .overlay(
                                                HStack {
                                                    Text(customAlarmMessages[index].isEmpty ? "Choose message \(index + 1)" : customAlarmMessages[index])
                                                        .foregroundColor(customAlarmMessages[index].isEmpty ? .gray : .white)
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
                                    .buttonStyle(PlainButtonStyle())
                                    .frame(height: 50)
                                }
                            }
                        }
                        
                        // Voice Selection Section
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
                                                        Text(customVoiceNames[index])
                                                            .foregroundColor(.white)
                                                            .font(.system(size: 16, weight: .medium))
                                                        if !customAlarmMessages[index].isEmpty {
                                                            Text(customAlarmMessages[index])
                                                                .foregroundColor(.gray)
                                                                .font(.system(size: 12))
                                                                .lineLimit(1)
                                                                .truncationMode(.tail)
                                                        }
                                                    }
                                                    Spacer()
                                                    if selectedVoiceForMessage == index {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(.neonGreen)
                                                            .font(.title2)
                                                    }
                                                }
                                                .padding()
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .frame(height: 60)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Action Buttons
                HStack(spacing: 15) {
                    Button(action: {
                        setVoiceAndMessage()
                    }) {
                        Text("Set")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.neonGreen)
                                    .shadow(color: .neonGreen.opacity(0.6), radius: 8, x: 0, y: 4)
                            )
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Close")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.neonGreen)
                                    .shadow(color: .neonGreen.opacity(0.6), radius: 8, x: 0, y: 4)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showingMessagePicker) {
            MessagePickerView(
                selectedMessage: $customAlarmMessages[selectedMessageIndex],
                predefinedMessages: predefinedMessages
            )
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
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
        // Check if at least one message is selected
        let hasSelectedMessage = customAlarmMessages.contains { !$0.isEmpty }
        
        if hasSelectedMessage {
            // Set the voice and message settings only
            let selectedMessage = customAlarmMessages.first { !$0.isEmpty } ?? "Alarm"
            let selectedVoiceName = customVoiceNames[selectedVoiceForMessage]
            let selectedVoiceID = customVoiceIDs[selectedVoiceForMessage]
            
            print("🎤 Voice and message settings configured:")
            print("📝 Message: \(selectedMessage)")
            print("🎵 Voice: \(selectedVoiceName)")
            print("🔑 Voice ID: \(selectedVoiceID)")
            
            // Just configure the settings without creating an alarm
            // The settings are now ready for when an alarm is actually created
            dismiss()
        } else {
            // Show feedback that a message needs to be selected
            print("⚠️ Please select a message before setting the voice and message")
        }
    }
    
    private func saveAlarm() {
        let alarmMessage = customAlarmMessages.first { !$0.isEmpty } ?? "Alarm"
        let newAlarm = Alarm(
            time: selectedTime,
            isEnabled: true,
            label: alarmMessage,
            repeatDays: []
        )
        
        alarms.append(newAlarm)
        scheduleNotification(for: newAlarm)
        dismiss()
    }
    
    private func scheduleNotification(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "I-RIZE Alarm"
        content.body = alarm.label
        content.sound = .default
        
        // Store alarm data for voice playback with selected voice
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
    
    private func playAudioFromData(_ data: Data) {
        do {
            print("🎵 Attempting to play audio data: \(data.count) bytes")
            
            // Check if data is valid
            guard data.count > 0 else {
                print("❌ Audio data is empty")
                return
            }
            
            // Check if data looks like valid audio (should be larger than a few bytes)
            guard data.count > 100 else {
                print("❌ Audio data too small (\(data.count) bytes) - likely not valid audio")
                return
            }
            
            #if os(iOS)
            // For new iOS devices, we need to set up audio session properly
            let audioSession = AVAudioSession.sharedInstance()
            
            // Check if we need to request audio permissions
            if audioSession.category != .playback {
                print("🔧 Setting up audio session for new iOS device...")
                try audioSession.setCategory(.playback, mode: .default, options: [])
                try audioSession.setActive(true, options: [])
                
                // Request audio focus
                try audioSession.setActive(true)
                print("✅ Audio session activated")
            }
            
            // Check device volume and settings
            let currentVolume = audioSession.outputVolume
            print("📱 Device volume: \(currentVolume)")
            
            if currentVolume < 0.1 {
                print("⚠️ CRITICAL: Device volume is very low! Please turn up your device volume.")
                print("📱 Go to Settings > Sounds & Haptics and turn up the volume")
            }
            
            // Check if device is on silent mode
            if audioSession.outputVolume == 0 {
                print("🔇 WARNING: Device might be on silent mode!")
                print("📱 Check the silent switch on the side of your phone")
            }
            #endif
            
            // Try playing with proper audio session setup
            print("🎵 Creating audio player...")
            let audioPlayer = try AVAudioPlayer(data: data)
            
            // Check if audio player is ready
            guard audioPlayer.duration > 0 else {
                print("❌ Audio player has no duration - invalid audio data")
                return
            }
            
            // Set volume to maximum and enable speaker
            audioPlayer.volume = 1.0
            audioPlayer.prepareToPlay()
            
            let success = audioPlayer.play()
            print("🎵 Audio player started: \(success)")
            print("🎵 Audio duration: \(audioPlayer.duration) seconds")
            print("🎵 Audio volume: \(audioPlayer.volume)")
            
            if success {
                print("✅ Audio is now playing")
                
                // Keep the audio player alive and check if it's actually playing
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if audioPlayer.isPlaying {
                        print("✅ Audio is still playing after 1 second")
                    } else {
                        print("❌ Audio stopped playing unexpectedly")
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + audioPlayer.duration + 1) {
                    print("🎵 Audio playback should have finished")
                }
            } else {
                print("❌ Audio player failed to start")
                
                // Try alternative method for new iOS devices
                print("🔄 Trying alternative playback method...")
                try? self.playAudioAlternative(data)
            }
            
        } catch {
            print("❌ Error playing audio: \(error)")
            print("Error details: \(error.localizedDescription)")
            
            // Try to save the audio data to debug
            #if os(iOS)
            if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let audioFileURL = documentsPath.appendingPathComponent("debug_audio.mp3")
                try? data.write(to: audioFileURL)
                print("🔍 Debug audio saved to: \(audioFileURL.path)")
                
                // Also save as .wav to test different format
                let wavFileURL = documentsPath.appendingPathComponent("debug_audio.wav")
                try? data.write(to: wavFileURL)
                print("🔍 Debug audio (WAV) saved to: \(wavFileURL.path)")
            }
            #endif
        }
    }
    
    private func playAudioAlternative(_ data: Data) throws {
        print("🎵 Trying alternative audio playback method...")
        
        #if os(iOS)
        // Force audio session to speaker output
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default, options: [.defaultToSpeaker])
        try audioSession.setActive(true, options: [])
        print("🔊 Set audio to speaker output")
        #endif
        
        let audioPlayer = try AVAudioPlayer(data: data)
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

// Sentence Picker View
struct SentencePickerView: View {
    @Binding var selectedSentence: String
    let sentences: [String]
    @Environment(\.dismiss) var dismiss
    @State private var customText = ""
    @State private var isCustomMode = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Choose Alarm Message")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            // Custom Text Input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Type Your Own Message")
                                    .font(.headline)
                                    .foregroundColor(.neonGreen)
                                    .padding(.leading, 5)
                                
                                TextField("Enter your custom message...", text: $customText)
                                    .foregroundColor(.white)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .placeholder(when: customText.isEmpty) {
                                        Text("Enter your custom message...")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.2))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.neonGreen.opacity(0.5), lineWidth: 1)
                                    )
                                
                                Button(action: {
                                    if !customText.isEmpty {
                                        selectedSentence = customText
                                        dismiss()
                                    }
                                }) {
                                    Text("Use Custom Message")
                                        .foregroundColor(.black)
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 40)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(customText.isEmpty ? Color.gray.opacity(0.3) : Color.neonGreen)
                                        )
                                }
                                .disabled(customText.isEmpty)
                            }
                            .padding(.bottom, 20)
                            
                            // Divider
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                                .padding(.horizontal, 20)
                            
                            // Pre-made Messages
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Or Choose from Suggestions")
                                    .font(.headline)
                                    .foregroundColor(.neonGreen)
                                    .padding(.leading, 5)
                                
                                ForEach(sentences, id: \.self) { sentence in
                                    Button(action: {
                                        selectedSentence = sentence
                                        dismiss()
                                    }) {
                                        HStack {
                                            Text(sentence)
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.leading)
                                            Spacer()
                                            if selectedSentence == sentence {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.neonGreen)
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(selectedSentence == sentence ? Color.neonGreen.opacity(0.2) : Color.gray.opacity(0.2))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedSentence == sentence ? Color.neonGreen : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
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

// Voice Picker View
struct VoicePickerView: View {
    @Binding var selectedVoiceID: String
    let availableVoices: [Voice]
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    var filteredVoices: [Voice] {
        if searchText.isEmpty {
            return availableVoices
        } else {
            return availableVoices.filter { voice in
                voice.name.localizedCaseInsensitiveContains(searchText) ||
                voice.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search voices...", text: $searchText)
                            .foregroundColor(.white)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.neonGreen.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Voices List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredVoices, id: \.id) { voice in
                                VoiceRowView(
                                    voice: voice,
                                    isSelected: selectedVoiceID == voice.id,
                                    onSelect: {
                                        selectedVoiceID = voice.id
                                        dismiss()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationTitle("Select Voice")
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

// Voice Row View
struct VoiceRowView: View {
    let voice: Voice
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(voice.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(voice.category)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let description = voice.description {
                        Text(description)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .lineLimit(2)
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
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.neonGreen.opacity(0.2) : Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.neonGreen : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Placeholder extension for TextField
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// Message Picker View
struct MessagePickerView: View {
    @Binding var selectedMessage: String
    let predefinedMessages: [String]
    @Environment(\.dismiss) var dismiss
    
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
                                    HStack {
                                        Text(message)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                            .font(.system(size: 16, weight: .medium))
                                        Spacer()
                                        if selectedMessage == message {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.neonGreen)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedMessage == message ? Color.neonGreen.opacity(0.2) : Color.black)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedMessage == message ? Color.neonGreen : Color.gray.opacity(0.3), lineWidth: 1)
                                            )
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

#Preview {
    ContentView()
} 
