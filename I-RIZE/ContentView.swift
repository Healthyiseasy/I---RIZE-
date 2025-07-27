import SwiftUI
import UserNotifications
import AVFoundation

struct ContentView: View {
    @State private var currentTime = Date()
    @State private var showingAlarmSheet = false
    @State private var showingSettings = false
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
                    Text(timeString)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.neonGreen)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        // Signal bars
                        HStack(spacing: 2) {
                            ForEach(0..<3, id: \.self) { index in
                                Rectangle()
                                    .fill(Color.neonGreen)
                                    .frame(width: 3, height: 8 + CGFloat(index * 2))
                            }
                        }
                        
                        Text("5G")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.neonGreen)
                        
                        // Battery
                        HStack(spacing: 2) {
                            Rectangle()
                                .fill(Color.neonGreen)
                                .frame(width: 20, height: 10)
                                .overlay(
                                    Rectangle()
                                        .fill(Color.black)
                                        .frame(width: 16, height: 6)
                                )
                            Rectangle()
                                .fill(Color.neonGreen)
                                .frame(width: 2, height: 4)
                        }
                        
                        Text("777%")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.neonGreen)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
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
                                .font(.custom("Digital-7", size: 48, relativeTo: .largeTitle))
                                .fontWeight(.bold)
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
                    
                    // Settings button
                    Button(action: {
                        showingSettings = true
                    }) {
                        HStack {
                            Image(systemName: "gearshape")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Settings")
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
        .sheet(isPresented: $showingSettings) {
            SetAlarmView(alarms: $alarms)
        }
        .onAppear {
            requestNotificationPermission()
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
}

// MARK: - ElevenLabs API Configuration
// Add your ElevenLabs API key and voice IDs here
struct ElevenLabsConfig {
    // Replace with your actual ElevenLabs API key
    static let apiKey = "YOUR_ELEVENLABS_API_KEY_HERE"
    
    // Replace with your actual voice IDs from ElevenLabs
    static let voiceIDs = [
        "voice1": "YOUR_FIRST_VOICE_ID_HERE",
        "voice2": "YOUR_SECOND_VOICE_ID_HERE", 
        "voice3": "YOUR_THIRD_VOICE_ID_HERE",
        "voice4": "YOUR_FOURTH_VOICE_ID_HERE",
        "voice5": "YOUR_FIFTH_VOICE_ID_HERE"
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
    
    private init() {}
    
    func generateSpeech(text: String, voiceID: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: "\(ElevenLabsConfig.baseURL)\(ElevenLabsConfig.textToSpeechEndpoint)/\(voiceID)") else {
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
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("ElevenLabs API Error: \(error)")
                    completion(nil)
                } else {
                    completion(data)
                }
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
    @State private var alarmLabels: [String] = ["", "", ""]
    
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
                    
                    // Alarm Labels Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Alarm Labels")
                            .font(.headline)
                            .foregroundColor(.neonGreen)
                            .padding(.leading, 5)
                        ForEach(alarmLabels.indices, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.neonGreen, lineWidth: 2)
                                        .shadow(color: .neonGreen.opacity(0.6), radius: 6, x: 0, y: 0)
                                )
                                .overlay(
                                    TextField("", text: $alarmLabels[index])
                                        .foregroundColor(.white)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .overlay(
                                            Group {
                                                if alarmLabels[index].isEmpty {
                                                    HStack {
                                                        Text("Alarm Label \(index + 1)")
                                                            .foregroundColor(.gray)
                                                            .padding(.leading, 16)
                                                        Spacer()
                                                    }
                                                }
                                            }
                                        )
                                        .padding()
                                )
                                .frame(height: 50)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 15) {
                        Button(action: {
                            // Create alarm with current time and labels
                            let labels = alarmLabels.filter { !$0.isEmpty }
                            let alarmLabel = labels.isEmpty ? "Alarm" : labels.joined(separator: ", ")
                            let newAlarm = Alarm(time: selectedTime, isEnabled: true, label: alarmLabel, repeatDays: [])
                            alarms.append(newAlarm)
                            scheduleNotification(for: newAlarm)
                            // Dismiss the page after setting alarm
                            dismiss()
                        }) {
                            Text("Set Alarm")
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
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: alarm.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

// Set Alarm view with full functionality
struct SetAlarmView: View {
    @Binding var alarms: [Alarm]
    @Environment(\.dismiss) var dismiss
    @State private var selectedTime = Date()
    @State private var customAlarmMessages: [String] = ["", "", "", "", ""]
    @State private var customVoiceNames: [String] = ["", "", "", "", ""]
    
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
                            
                        

                        
                        // Custom Alarm Message Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Custom Alarm Messages")
                                .font(.headline)
                                .foregroundColor(.neonGreen)
                                .padding(.leading, 5)
                            
                            VStack(spacing: 8) {
                                ForEach(0..<5, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.neonGreen, lineWidth: 2)
                                                .shadow(color: .neonGreen.opacity(0.6), radius: 6, x: 0, y: 0)
                                        )
                                        .overlay(
                                            TextField("Type your alarm message here...", text: $customAlarmMessages[index], axis: .vertical)
                                                .foregroundColor(.white)
                                                .textFieldStyle(PlainTextFieldStyle())
                                                .placeholder(when: customAlarmMessages[index].isEmpty) {
                                                    Text("Type your alarm message here...")
                                                        .foregroundColor(.gray)
                                                }
                                                .lineLimit(1...2)
                                                .padding()
                                        )
                                        .frame(height: 50)
                                }
                            }
                        }
                        
                        // Custom Alarm Voice Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Custom Alarm Voices")
                                .font(.headline)
                                .foregroundColor(.neonGreen)
                                .padding(.leading, 5)
                            
                            VStack(spacing: 8) {
                                ForEach(0..<5, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.neonGreen, lineWidth: 2)
                                                .shadow(color: .neonGreen.opacity(0.6), radius: 6, x: 0, y: 0)
                                        )
                                        .overlay(
                                            TextField("Voice name", text: $customVoiceNames[index])
                                                .foregroundColor(.white)
                                                .textFieldStyle(PlainTextFieldStyle())
                                                .placeholder(when: customVoiceNames[index].isEmpty) {
                                                    Text("Voice name")
                                                        .foregroundColor(.gray)
                                                }
                                                .padding()
                                        )
                                        .frame(height: 50)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Action Buttons
                VStack(spacing: 10) {
                    Button(action: {
                        testVoice()
                    }) {
                        Text("Test Voice")
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
                    
                    HStack(spacing: 15) {
                        Button(action: {
                            saveAlarm()
                        }) {
                            Text("Save Alarm")
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
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
    }
    
    private var selectedTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: selectedTime)
    }
    
    private func testVoice() {
        // Voice testing functionality
        let testMessage = customAlarmMessages.first { !$0.isEmpty } ?? "Test message"
        let utterance = AVSpeechUtterance(string: testMessage)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
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
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: alarm.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
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

#Preview {
    ContentView()
} 