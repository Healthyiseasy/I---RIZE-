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
            AlarmSheetView(alarms: $alarms, onRemoveNotification: removeNotification)
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
                .foregroundColor(Color("NeonGreen"))
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
                    .stroke(Color("NeonGreen"), lineWidth: 2)
            )
            .overlay(
                Text(mainTimeString)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(Color("NeonGreen"))
                    .shadow(color: Color("NeonGreen").opacity(0.8), radius: 10, x: 0, y: 0)
            )
            .frame(height: 120)
            .padding(.horizontal, 40)
    }
    
    private var dateDisplayView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("NeonGreen"), lineWidth: 1.5)
            )
            .overlay(
                Text(dateString)
                    .font(.system(size: 18, weight: .medium, design: .monospaced))
                    .foregroundColor(Color("NeonGreen"))
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
                        .foregroundColor(Color("NeonGreen"))
                        .padding(.leading, 20)
                    
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(alarms.indices, id: \.self) { index in
                                AlarmRowView(
                                    alarm: alarms[index],
                                    onDelete: {
                                        removeNotification(for: alarms[index])
                                        alarms.remove(at: index)
                                        
                                        // If this was the last alarm, also clear all notifications
                                        if alarms.isEmpty {
                                            removeAllNotifications()
                                            print("🔔 Last alarm removed - cleared all notifications")
                                        }
                                    },
                                    onClearAll: removeAllNotifications
                                )
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                    
                    // Hint about long-press functionality
                    if !alarms.isEmpty {
                        Text("💡 Long-press any trash button to clear all notifications")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 5)
                    }
                }
            }
        }
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 15) {
            HStack(spacing: 20) {
                setAlarmButton
            }
            .padding(.horizontal, 40)
            
            // Test notification button
            Button(action: {
                testNotification()
            }) {
                HStack {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Test Notification")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange)
                        .shadow(color: Color.orange.opacity(0.6), radius: 4, x: 0, y: 2)
                )
            }
            .padding(.horizontal, 60)
            
            // Check ElevenLabs configuration button
            Button(action: {
                checkElevenLabsConfig()
            }) {
                HStack {
                    Image(systemName: "gear.badge.checkmark")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Check ElevenLabs Config")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red)
                        .shadow(color: Color.red.opacity(0.6), radius: 4, x: 0, y: 2)
                )
            }
            .padding(.horizontal, 60)
            
            // Hint about long-press functionality
            Text("💡 Long-press Set Alarm button to clear all alarms")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
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
                    .fill(Color("NeonGreen"))
                    .shadow(color: Color("NeonGreen").opacity(0.6), radius: 8, x: 0, y: 4)
            )
        }
        .onLongPressGesture(minimumDuration: 1.0) {
            removeAllNotifications()
            alarms.removeAll()
            print("🔔 Long-pressed Set Alarm button - cleared all alarms and notifications")
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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .provisional]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Notification permission granted")
                    // Check current notification settings
                    self.checkNotificationSettings()
                } else {
                    print("❌ Notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    private func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                print("📱 Notification settings:")
                print("   - Authorization status: \(settings.authorizationStatus.rawValue)")
                print("   - Alert setting: \(settings.alertSetting.rawValue)")
                print("   - Sound setting: \(settings.soundSetting.rawValue)")
                print("   - Badge setting: \(settings.badgeSetting.rawValue)")
                
                if settings.authorizationStatus == .denied {
                    print("⚠️ WARNING: Notifications are denied! Please enable in Settings > I-RIZE > Notifications")
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
    
    private func testNotification() {
        print("🧪 Testing notification system...")
        
        // Check notification permissions
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                print("📱 Current notification settings:")
                print("   - Authorization: \(settings.authorizationStatus.rawValue)")
                print("   - Alert: \(settings.alertSetting.rawValue)")
                print("   - Sound: \(settings.soundSetting.rawValue)")
                print("   - Badge: \(settings.badgeSetting.rawValue)")
                
                if settings.authorizationStatus == .authorized {
                    // Send a test notification
                    let content = UNMutableNotificationContent()
                    content.title = "Test Alarm"
                    content.body = "This is a test notification to verify the system works"
                    content.sound = .default
                    content.userInfo = [
                        "message": "This is a test alarm message",
                        "voiceName": "Simeon",
                        "alarmID": "test-123"
                    ]
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
                    let request = UNNotificationRequest(identifier: "test-notification", content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                print("❌ Test notification failed: \(error.localizedDescription)")
                            } else {
                                print("✅ Test notification scheduled successfully")
                                print("🔔 Will fire in 3 seconds")
                            }
                        }
                    }
                } else {
                    print("❌ Notifications not authorized - cannot send test")
                }
            }
        }
    }
    
    private func checkElevenLabsConfig() {
        print("🔧 Checking ElevenLabs configuration...")
        
        let errors = ElevenLabsConfig.validateConfiguration()
        
        if errors.isEmpty {
            print("✅ ElevenLabs configuration is valid!")
            print("🔑 API Key: Configured")
            print("🎭 Voice IDs: All configured")
        } else {
            print("❌ ElevenLabs configuration has errors:")
            for error in errors {
                print(error)
            }
            print("\n📋 TO FIX THESE ERRORS:")
            print("1. Go to https://elevenlabs.io/")
            print("2. Sign in to your account")
            print("3. Get your API key from Profile → API Key")
            print("4. Get Voice IDs from Voice Library → Copy Voice ID")
            print("5. Replace the placeholder values in ElevenLabsConfig")
        }
    }
    

}

// MARK: - Alarm Row View
struct AlarmRowView: View {
    let alarm: Alarm
    let onDelete: () -> Void
    let onClearAll: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("NeonGreen"), lineWidth: 2)
                    .shadow(color: Color("NeonGreen").opacity(0.6), radius: 6, x: 0, y: 0)
            )
            .overlay(
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(alarm.label)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(alarm.time, style: .time)
                            .font(.subheadline)
                            .foregroundColor(Color("NeonGreen"))
                    }
                    Spacer()
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .onLongPressGesture(minimumDuration: 1.0) {
                        onClearAll()
                        print("🔔 Long-pressed trash button - cleared all notifications")
                    }
                }
                .padding()
            )
            .frame(height: 60)
            .padding(.horizontal, 20)
    }
}

// MARK: - ElevenLabs Configuration
// This configuration provides different voice keys and settings for each  character:
// - Simeon: Friendly and approachable voice
// - Rachel: Warm and caring voice  
// - Domi: Energetic and dynamic voice
// - Mr. Rubio: Professional and authoritative voice
//
// To use different voices, simply pass the character name to the generateSpeech method:
// elevenLabsService.generateSpeech(text: "Hello!", voiceName: "Simeon")
// elevenLabsService.generateSpeech(text: "Welcome!", voiceName: "Rachel")
// elevenLabsService.generateSpeech(text: "Let's go!", voiceName: "Domi")
// elevenLabsService.generateSpeech(text: "Important message", voiceName: "Mr. Rubio")
struct ElevenLabsConfig {
    // MARK: - API Configuration
    // ⚠️ IMPORTANT: Replace with your actual ElevenLabs API key
    // Get it from: https://elevenlabs.io/ → Profile → API Key
    static let apiKey = "YOUR_ACTUAL_API_KEY_HERE"
    static let baseURL = "https://api.elevenlabs.io/v1"
    static let textToSpeechEndpoint = "/text-to-speech"
    
    // MARK: - Voice ID Configuration
    // ⚠️ IMPORTANT: Replace these with your actual ElevenLabs Voice IDs
    // Get them from: https://elevenlabs.io/ → Voice Library → Copy Voice ID
    static let simeonVoiceID = "YOUR_SIMEON_VOICE_ID"  // Replace with actual Simeon voice ID
    static let rachelVoiceID = "YOUR_RACHEL_VOICE_ID"  // Replace with actual Rachel voice ID
    static let domiVoiceID = "YOUR_DOMI_VOICE_ID"      // Replace with actual Domi voice ID
    static let mrRubioVoiceID = "YOUR_MR_RUBIO_VOICE_ID" // Replace with actual Mr. Rubio voice ID
    
    // Voice IDs for different character voices
    static let voiceIDs = [
        "Simeon": simeonVoiceID,
        "Rachel": rachelVoiceID,
        "Domi": domiVoiceID,
        "Mr. Rubio": mrRubioVoiceID,
        "voice1": "",
        "voice2": "",
        "voice3": "",
        "voice4": "",
        "voice5": ""
    ]
    
    // Get available character voice names
    static func getAvailableCharacterVoiceNames() -> [String] {
        return ["Simeon", "Rachel", "Domi", "Mr. Rubio"]
    }
    
    // Validate configuration
    static func validateConfiguration() -> [String] {
        var errors: [String] = []
        
        // Check API key
        if apiKey == "YOUR_ACTUAL_API_KEY_HERE" || apiKey.isEmpty {
            errors.append("❌ API Key not configured - Replace 'YOUR_ACTUAL_API_KEY_HERE' with your real API key")
        }
        
        // Check voice IDs
        if simeonVoiceID == "YOUR_SIMEON_VOICE_ID" || simeonVoiceID.isEmpty {
            errors.append("❌ Simeon Voice ID not configured")
        }
        if rachelVoiceID == "YOUR_RACHEL_VOICE_ID" || rachelVoiceID.isEmpty {
            errors.append("❌ Rachel Voice ID not configured")
        }
        if domiVoiceID == "YOUR_DOMI_VOICE_ID" || domiVoiceID.isEmpty {
            errors.append("❌ Domi Voice ID not configured")
        }
        if mrRubioVoiceID == "YOUR_MR_RUBIO_VOICE_ID" || mrRubioVoiceID.isEmpty {
            errors.append("❌ Mr. Rubio Voice ID not configured")
        }
        
        return errors
    }
    
    static let voiceSettings: [String: Any] = [
        "stability": 0.5,
        "similarity_boost": 0.75,
        "style": 0.0,
        "use_speaker_boost": true
    ]
    
    // Custom voice settings for Mr. Rubio (more professional/authoritative)
    static let mrRubioVoiceSettings: [String: Any] = [
        "stability": 0.7,        // Higher stability for consistent professional tone
        "similarity_boost": 0.8, // Higher similarity for clear pronunciation
        "style": 0.2,            // Slight style boost for character
        "use_speaker_boost": true
    ]
    
    // Custom voice settings for Simeon (friendly and approachable)
    static let simeonVoiceSettings: [String: Any] = [
        "stability": 0.6,        // Balanced stability for natural conversation
        "similarity_boost": 0.7, // Good similarity for clear speech
        "style": 0.3,            // Style boost for personality
        "use_speaker_boost": true
    ]
    
    // Custom voice settings for Rachel (warm and caring)
    static let rachelVoiceSettings: [String: Any] = [
        "stability": 0.65,       // Stable but expressive
        "similarity_boost": 0.75, // Clear pronunciation
        "style": 0.4,            // Higher style for warmth
        "use_speaker_boost": true
    ]
    
    // Custom voice settings for Domi (energetic and dynamic)
    static let domiVoiceSettings: [String: Any] = [
        "stability": 0.55,       // Lower stability for more dynamic expression
        "similarity_boost": 0.7, // Good similarity
        "style": 0.5,            // Higher style for energy
        "use_speaker_boost": true
    ]
}

// MARK: - ElevenLabs Service
final class ElevenLabsService {
    static let shared = ElevenLabsService()
    
    private init() {}
    
    func generateSpeech(text: String, voiceName: String, completion: @escaping (Data?) -> Void) {
        // Get the voice ID from the voice name
        guard let voiceID = ElevenLabsConfig.voiceIDs[voiceName] else {
            print("❌ Voice not found: \(voiceName)")
            completion(nil)
            return
        }
        
        guard let url = URL(string: "\(ElevenLabsConfig.baseURL)\(ElevenLabsConfig.textToSpeechEndpoint)/\(voiceID)") else {
            print("Invalid URL for voice ID: \(voiceID)")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(ElevenLabsConfig.apiKey, forHTTPHeaderField: "xi-api-key")
        
        // Use appropriate voice settings based on the voice name
        let voiceSettings: [String: Any]
        switch voiceName {
        case "Mr. Rubio":
            voiceSettings = ElevenLabsConfig.mrRubioVoiceSettings
        case "Simeon":
            voiceSettings = ElevenLabsConfig.simeonVoiceSettings
        case "Rachel":
            voiceSettings = ElevenLabsConfig.rachelVoiceSettings
        case "Domi":
            voiceSettings = ElevenLabsConfig.domiVoiceSettings
        default:
            voiceSettings = ElevenLabsConfig.voiceSettings
        }
        
        let requestBody: [String: Any] = [
            "text": text,
            "model_id": "eleven_monolingual_v1",
            "voice_settings": voiceSettings
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
    
    // Get available voice names from our configuration
    func getAvailableVoiceNames() -> [String] {
        return Array(ElevenLabsConfig.voiceIDs.keys).filter { !$0.isEmpty }
    }
    
    // Get available character voice names specifically
    func getAvailableCharacterVoiceNames() -> [String] {
        return ["Simeon", "Rachel", "Domi", "Mr. Rubio"]
    }
    
    // Get voice settings for a specific character
    func getVoiceSettings(for voiceName: String) -> [String: Any] {
        switch voiceName {
        case "Mr. Rubio":
            return ElevenLabsConfig.mrRubioVoiceSettings
        case "Simeon":
            return ElevenLabsConfig.simeonVoiceSettings
        case "Rachel":
            return ElevenLabsConfig.rachelVoiceSettings
        case "Domi":
            return ElevenLabsConfig.domiVoiceSettings
        default:
            return ElevenLabsConfig.voiceSettings
        }
    }
    
    // Validate if a voice name is a valid character voice
    func isValidCharacterVoice(_ voiceName: String) -> Bool {
        return getAvailableCharacterVoiceNames().contains(voiceName)
    }
    
    // Get voice ID for a specific character
    func getVoiceID(for characterName: String) -> String? {
        return ElevenLabsConfig.voiceIDs[characterName]
    }
    
    // Get comprehensive voice information for a character
    func getVoiceInfo(for characterName: String) -> (id: String?, settings: [String: Any])? {
        guard let voiceID = ElevenLabsConfig.voiceIDs[characterName] else {
            return nil
        }
        let settings = getVoiceSettings(for: characterName)
        return (id: voiceID, settings: settings)
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
        print("🔔 Notification will present: \(notification.request.identifier)")
        print("🔔 User info: \(notification.request.content.userInfo)")
        
        // Always show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
        
        // Handle the notification immediately
        handleNotification(notification)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("🔔 Notification response received: \(response.notification.request.identifier)")
        print("🔔 Action identifier: \(response.actionIdentifier)")
        
        handleNotification(response.notification)
        completionHandler()
    }
    
    private func handleNotification(_ notification: UNNotification) {
        print("🔔 Processing notification: \(notification.request.identifier)")
        print("🔔 Full user info: \(notification.request.content.userInfo)")
        
        let userInfo = notification.request.content.userInfo
        
        // Check if this is an alarm notification
        guard let message = userInfo["message"] as? String,
              let voiceName = userInfo["voiceName"] as? String else { 
            print("❌ Missing required notification data: message or voiceName")
            print("❌ Available keys: \(userInfo.keys)")
            return 
        }
        
        print("✅ Notification data validated:")
        print("   - Message: \(message)")
        print("   - Voice: \(voiceName)")
        print("   - Alarm ID: \(userInfo["alarmID"] ?? "Unknown")")
        
        // Check if voice is valid
        guard ElevenLabsConfig.voiceIDs[voiceName] != nil else {
            print("❌ Invalid voice name: \(voiceName)")
            print("❌ Available voices: \(ElevenLabsConfig.voiceIDs.keys)")
            return
        }
        
        print("🔔 Alarm triggered! Playing voice for message: \(message)")
        print("🎵 Using voice: \(voiceName)")
        
        // Generate speech with timeout
        let timeout = DispatchTime.now() + 30.0 // 30 second timeout
        elevenLabsService.generateSpeech(text: message, voiceName: voiceName) { audioData in
            if let audioData = audioData {
                print("✅ ElevenLabs audio generated successfully: \(audioData.count) bytes")
                DispatchQueue.main.async {
                    self.playAlarmVoice(audioData)
                }
            } else {
                print("❌ Failed to generate ElevenLabs audio")
                print("❌ This could be due to:")
                print("   - Invalid API key")
                print("   - Invalid voice ID")
                print("   - Network issues")
                print("   - ElevenLabs service error")
            }
        }
        
        // Check if we're taking too long
        DispatchQueue.main.asyncAfter(deadline: timeout) {
            print("⏰ ElevenLabs request timeout - audio may still be processing")
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
    var voiceName: String
    
    init(time: Date, isEnabled: Bool, label: String, repeatDays: [Int], voiceName: String) {
        self.id = UUID()
        self.time = time
        self.isEnabled = isEnabled
        self.label = label
        self.repeatDays = repeatDays
        self.voiceName = voiceName
    }
}

// MARK: - Quick Assignment Sheet
struct QuickAssignmentSheet: View {
    @Binding var customAlarmMessages: [String]
    @Binding var customVoiceNames: [String]
    @Binding var voiceMessageAssignments: [String: String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    titleView
                    assignmentMatrixView
                    actionButtonsView
                }
            }
            .navigationTitle("Voice-Message Assignment")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("NeonGreen"))
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("NeonGreen"))
                }
                #endif
            }
        }
    }
    
    private var titleView: some View {
        VStack(spacing: 10) {
            Text("Assign Messages to Voices")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Tap any cell to assign a message to a voice")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.top, 20)
    }
    
    private var assignmentMatrixView: some View {
        VStack(spacing: 15) {
            // Header row with voice names
            HStack(spacing: 0) {
                Text("Messages →")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 80, alignment: .leading)
                
                ForEach(customVoiceNames, id: \.self) { voiceName in
                    Text(voiceName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("NeonGreen"))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Matrix rows for each message
            ForEach(0..<customAlarmMessages.count, id: \.self) { messageIndex in
                HStack(spacing: 0) {
                    // Message label
                    Text("Message \(messageIndex + 1)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: 80, alignment: .leading)
                    
                    // Assignment cells for each voice
                    ForEach(customVoiceNames, id: \.self) { voiceName in
                        Button(action: {
                            assignMessageToVoice(messageIndex: messageIndex, voiceName: voiceName)
                        }) {
                            let isAssigned = voiceMessageAssignments[voiceName] == customAlarmMessages[messageIndex]
                            let hasMessage = !customAlarmMessages[messageIndex].isEmpty
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isAssigned && hasMessage ? Color("NeonGreen") : Color.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(hasMessage ? Color("NeonGreen") : Color.gray, lineWidth: 1)
                                )
                                .overlay(
                                    Group {
                                        if isAssigned && hasMessage {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.black)
                                                .font(.caption)
                                                .fontWeight(.bold)
                                        } else if hasMessage {
                                            Text("+")
                                                .foregroundColor(Color("NeonGreen"))
                                                .font(.caption)
                                                .fontWeight(.bold)
                                        } else {
                                            Text("-")
                                                .foregroundColor(.gray)
                                                .font(.caption)
                                        }
                                    }
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(height: 30)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 15) {
            // Clear all assignments
            Button("Clear All Assignments") {
                voiceMessageAssignments.removeAll()
            }
            .buttonStyle(PrimaryButtonStyle())
            
            // Apply same message to all voices
            Button("Apply Message 1 to All Voices") {
                if !customAlarmMessages[0].isEmpty {
                    for voiceName in customVoiceNames {
                        voiceMessageAssignments[voiceName] = customAlarmMessages[0]
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private func assignMessageToVoice(messageIndex: Int, voiceName: String) {
        let message = customAlarmMessages[messageIndex]
        if !message.isEmpty {
            voiceMessageAssignments[voiceName] = message
            print("🎤 Assigned '\(message)' to voice '\(voiceName)'")
        }
    }
}

// MARK: - Extensions
extension Color {
    // Removed duplicate color definition - using Color("NeonGreen") from assets
}

// MARK: - Alarm Sheet View
struct AlarmSheetView: View {
    @Binding var alarms: [Alarm]
    let onRemoveNotification: (Alarm) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTime = Date()
    @State private var customAlarmMessages = ["", "", "", ""]
    @State private var customVoiceNames = ["Simeon", "Rachel", "Domi", "Mr. Rubio"]
    @State private var selectedVoiceForMessage = 0
    @State private var showingConfiguration = false
    @State private var configuredVoiceName = "Simeon" // Default voice
    @State private var configuredMessage = "" // Will be set from SetAlarmView
    
    // New: For editing existing alarms
    @State private var editingAlarmIndex: Int? = nil
    @State private var isEditingMode = false
    
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
                SetAlarmView(
                    alarms: $alarms,
                    configuredVoiceName: $configuredVoiceName,
                    configuredMessage: $configuredMessage
                )
            }
        }
    }
    
    private var titleView: some View {
        Text(isEditingMode ? "Edit Alarm" : "Set Alarm")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.top, 20)
    }
    
    private var timePickerSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Alarm Time")
                .font(.headline)
                .foregroundColor(Color("NeonGreen"))
                .padding(.leading, 5)
            
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color("NeonGreen"), lineWidth: 2)
                        .shadow(color: Color("NeonGreen").opacity(0.6), radius: 8, x: 0, y: 0)
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
                .foregroundColor(Color("NeonGreen"))
                .padding(.leading, 5)
            
            Text(isEditingMode ? "Editing existing alarm. Change the time, message, or voice as needed." : "Each alarm slot can only hold one alarm. Tapping an occupied slot will edit the existing alarm.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 5)
            
            ForEach(0..<3, id: \.self) { index in
                Button(action: {
                    createAlarm(for: index)
                }) {
                    let isOccupied = alarms.contains { alarm in
                        alarm.label.contains("Alarm \(index + 1)")
                    }
                    let occupiedTime = alarms.first { alarm in
                        alarm.label.contains("Alarm \(index + 1)")
                    }?.time.formatted(date: .omitted, time: .shortened)
                    
                    AlarmSelectionRow(
                        title: "Alarm \(index + 1)",
                        isOccupied: isOccupied,
                        occupiedTime: occupiedTime,
                        isEditing: isEditingMode && editingAlarmIndex == index
                    )
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
            
            if isEditingMode {
                Button("Update Alarm") {
                    if let editingIndex = editingAlarmIndex {
                        createOrUpdateAlarm(for: editingIndex)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            
            Button(isEditingMode ? "Cancel Edit" : "Cancel") {
                // Reset editing mode if canceling
                if isEditingMode {
                    isEditingMode = false
                    editingAlarmIndex = nil
                    selectedTime = Date()
                    configuredMessage = ""
                    configuredVoiceName = "Simeon"
                }
                dismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private func createAlarm(for index: Int) {
        // Check if an alarm with this index already exists
        let existingAlarmIndex = alarms.firstIndex { alarm in
            alarm.label.contains("Alarm \(index + 1)")
        }
        
        if let existingIndex = existingAlarmIndex {
            // Alarm already exists - enter editing mode
            let existingAlarm = alarms[existingIndex]
            editingAlarmIndex = existingIndex
            selectedTime = existingAlarm.time
            configuredMessage = existingAlarm.label
            configuredVoiceName = existingAlarm.voiceName
            isEditingMode = true
            print("🔔 Entering edit mode for existing alarm \(index + 1)")
            return
        }
        
        // Create new alarm
        createOrUpdateAlarm(for: index)
    }
    
    private func createOrUpdateAlarm(for index: Int) {
        // Use configured message and voice if available, otherwise use defaults
        let alarmMessage = configuredMessage.isEmpty ? "Alarm \(index + 1)" : configuredMessage
        let selectedVoice = configuredVoiceName
        
        if isEditingMode, let editingIndex = editingAlarmIndex {
            // Update existing alarm
            let existingAlarm = alarms[editingIndex]
            onRemoveNotification(existingAlarm)
            
            let updatedAlarm = Alarm(
                time: selectedTime, 
                isEnabled: true, 
                label: alarmMessage, 
                repeatDays: [],
                voiceName: selectedVoice
            )
            alarms[editingIndex] = updatedAlarm
            scheduleNotification(for: updatedAlarm, voiceName: selectedVoice)
            
            print("🔔 Updated alarm: \(alarmMessage) with voice: \(selectedVoice)")
            print("🔔 Updated alarm details - Time: \(selectedTime), Message: \(alarmMessage), Voice: \(selectedVoice)")
            
            // Reset editing mode
            isEditingMode = false
            editingAlarmIndex = nil
        } else {
            // Create new alarm
            let newAlarm = Alarm(
                time: selectedTime, 
                isEnabled: true, 
                label: alarmMessage, 
                repeatDays: [],
                voiceName: selectedVoice
            )
            alarms.append(newAlarm)
            scheduleNotification(for: newAlarm, voiceName: selectedVoice)
            
            print("🔔 Created new alarm: \(alarmMessage) with voice: \(selectedVoice)")
            print("🔔 New alarm details - Time: \(selectedTime), Message: \(alarmMessage), Voice: \(selectedVoice)")
        }
        
        dismiss()
    }
    
    private func scheduleNotification(for alarm: Alarm, voiceName: String) {
        let content = UNMutableNotificationContent()
        content.title = "I-RIZE Alarm"
        content.body = alarm.label
        content.sound = .default
        content.categoryIdentifier = "ALARM_CATEGORY"
        
        let alarmData: [String: Any] = [
            "message": alarm.label,
            "voiceName": voiceName,
            "alarmID": alarm.id.uuidString
        ]
        content.userInfo = alarmData
        
        // Calculate next occurrence of this time
        let calendar = Calendar.current
        let now = Date()
        var targetDate = alarm.time
        
        // If the alarm time has already passed today, schedule for tomorrow
        if targetDate <= now {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate) ?? targetDate
        }
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: targetDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Failed to schedule notification: \(error.localizedDescription)")
                } else {
                    print("✅ Successfully scheduled alarm for \(alarm.label)")
                    print("🔔 Scheduled for: \(targetDate)")
                    print("🔔 Using voice: \(voiceName)")
                    print("🔔 Notification ID: \(alarm.id.uuidString)")
                    
                    // Verify the notification was scheduled
                    self.verifyNotificationScheduled(for: alarm.id.uuidString)
                }
            }
        }
    }
    
    private func verifyNotificationScheduled(for identifier: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let matchingRequest = requests.first { $0.identifier == identifier }
            if let request = matchingRequest {
                print("✅ Verified notification scheduled: \(request.identifier)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("🔔 Next fire date: \(trigger.nextTriggerDate()?.description ?? "Unknown")")
                }
            } else {
                print("❌ Notification verification failed: \(identifier) not found in pending requests")
            }
        }
    }
}

// MARK: - Supporting Views
struct AlarmSelectionRow: View {
    let title: String
    let isOccupied: Bool
    let occupiedTime: String?
    let isEditing: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(strokeColor, lineWidth: 2)
                    .shadow(color: strokeColor.opacity(0.6), radius: 6, x: 0, y: 0)
            )
            .overlay(
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                        if isOccupied, let time = occupiedTime {
                            Text(isEditing ? "Editing - Set for \(time)" : "Set for \(time)")
                                .foregroundColor(isEditing ? Color("NeonGreen") : .orange)
                                .font(.caption)
                        }
                    }
                    Spacer()
                    Image(systemName: iconName)
                        .foregroundColor(iconColor)
                }
                .padding()
            )
    }
    
    private var strokeColor: Color {
        if isEditing {
            return Color("NeonGreen")
        } else if isOccupied {
            return .orange
        } else {
            return Color("NeonGreen")
        }
    }
    
    private var iconName: String {
        if isEditing {
            return "pencil.circle.fill"
        } else if isOccupied {
            return "clock.fill"
        } else {
            return "chevron.right"
        }
    }
    
    private var iconColor: Color {
        if isEditing {
            return Color("NeonGreen")
        } else if isOccupied {
            return .orange
        } else {
            return Color("NeonGreen")
        }
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
                    .fill(Color("NeonGreen"))
                    .shadow(color: Color("NeonGreen").opacity(0.6), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Set Alarm View
struct SetAlarmView: View {
    @Binding var alarms: [Alarm]
    @Binding var configuredVoiceName: String
    @Binding var configuredMessage: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTime = Date()
    @State private var customAlarmMessages = ["", "", "", ""]
    @State private var customVoiceNames = ["Simeon", "Rachel", "Domi", "Mr. Rubio"]
    @State private var showingMessagePicker = false
    @State private var selectedMessageIndex = 0
    @State private var selectedVoiceForMessage = 0
    
    // New: Voice-Message assignment mapping
    @State private var voiceMessageAssignments: [String: String] = [:]
    @State private var showingQuickAssignSheet = false
    
    // Debug: Print voice configuration on init
    init(alarms: Binding<[Alarm]>, configuredVoiceName: Binding<String>, configuredMessage: Binding<String>) {
        self._alarms = alarms
        self._configuredVoiceName = configuredVoiceName
        self._configuredMessage = configuredMessage
        print("🎤 SetAlarmView initialized with voices: \(["Simeon", "Rachel", "Domi", "Mr. Rubio"])")
        print("🎤 Voice count: \(["Simeon", "Rachel", "Domi", "Mr. Rubio"].count)")
    }
    
    private let predefinedMessages = [
        "Wake up! It's a new day and a new chance to take control. You've got breath in your lungs, strength in your body, and fire in your spirit. No more snoozing through your potential — get up and show life exactly who you are. You're built for progress, made for impact, and today is yours to dominate. Let's move. Let's rise. Let's win.",
        "YOUR PARAGRAPH 2 HERE - Write your custom alarm message paragraph here",
        "YOUR PARAGRAPH 3 HERE - Write your custom alarm message paragraph here",
        "YOUR PARAGRAPH 4 HERE - Write your custom alarm message paragraph here"
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                titleView
                ScrollView(showsIndicators: false) {
                                VStack(spacing: 20) {
                alarmMessagesSection
                quickAssignmentSection
                voiceSelectionSection
                currentConfigurationSection
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
        .sheet(isPresented: $showingQuickAssignSheet) {
            QuickAssignmentSheet(
                customAlarmMessages: $customAlarmMessages,
                customVoiceNames: $customVoiceNames,
                voiceMessageAssignments: $voiceMessageAssignments
            )
        }
        .onAppear {
            print("🎤 SetAlarmView appeared with voices: \(customVoiceNames)")
            print("🎤 Voice count: \(customVoiceNames.count)")
            print("🎤 Messages count: \(customAlarmMessages.count)")
            
            // Initialize configuration if not already set
            if configuredVoiceName.isEmpty {
                configuredVoiceName = customVoiceNames[0] // Default to first voice
            }
            if configuredMessage.isEmpty {
                // Find first non-empty message
                if let firstMessage = customAlarmMessages.first(where: { !$0.isEmpty }) {
                    configuredMessage = firstMessage
                }
            }
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
                .foregroundColor(Color("NeonGreen"))
                .padding(.leading, 5)
            
            VStack(spacing: 8) {
                ForEach(0..<customAlarmMessages.count, id: \.self) { index in
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
    
    private var quickAssignmentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Voice-Message Assignment")
                .font(.headline)
                .foregroundColor(Color("NeonGreen"))
                .padding(.leading, 5)
            
            Text("Quickly assign messages to voices or mix and match")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 5)
            
            VStack(spacing: 8) {
                // Individual voice-message assignment
                Button(action: {
                    showingQuickAssignSheet = true
                }) {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(Color("NeonGreen"))
                        Text("Custom Voice-Message Assignments")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .foregroundColor(Color("NeonGreen"))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("NeonGreen"), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var voiceSelectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Current Voice-Message Assignments")
                .font(.headline)
                .foregroundColor(Color("NeonGreen"))
                .padding(.leading, 5)
            
            Text("Shows current assignments from the quick assignment matrix")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 5)
            
            VStack(spacing: 8) {
                ForEach(customVoiceNames, id: \.self) { voiceName in
                    let assignedMessage = voiceMessageAssignments[voiceName] ?? "No message assigned"
                    let hasAssignment = voiceMessageAssignments[voiceName] != nil
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(voiceName)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                            Text(assignedMessage)
                                .foregroundColor(hasAssignment ? Color("NeonGreen") : .gray)
                                .font(.caption)
                                .lineLimit(2)
                                .truncationMode(.tail)
                        }
                        Spacer()
                        if hasAssignment {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color("NeonGreen"))
                                .font(.title2)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(hasAssignment ? Color("NeonGreen") : Color.gray, lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
    
    private var currentConfigurationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Current Configuration")
                .font(.headline)
                .foregroundColor(Color("NeonGreen"))
                .padding(.leading, 5)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Selected Voice:")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                    Spacer()
                    Text(configuredVoiceName)
                        .foregroundColor(Color("NeonGreen"))
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("NeonGreen"), lineWidth: 1)
                        )
                )
                
                HStack {
                    Text("Selected Message:")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                    Spacer()
                    Text(configuredMessage.isEmpty ? "No message selected" : "Message configured")
                        .foregroundColor(configuredMessage.isEmpty ? .gray : Color("NeonGreen"))
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("NeonGreen"), lineWidth: 1)
                        )
                )
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
    
    private func onMessageSelected(_ message: String) {
        customAlarmMessages[selectedMessageIndex] = message
        configuredMessage = message
        print("📝 Message selected: \(message)")
    }
    
    private func selectVoiceForMessage(index: Int) {
        selectedVoiceForMessage = index
        print("🎤 Selected voice: \(customVoiceNames[index]) for message")
        print("🎤 Available voices: \(customVoiceNames)")
        print("🎤 Selected index: \(index)")
        
        // Update the configured voice name immediately
        configuredVoiceName = customVoiceNames[index]
    }
    
    private func setVoiceAndMessage() {
        let hasSelectedMessage = customAlarmMessages.contains { !$0.isEmpty }
        
        if hasSelectedMessage {
            let selectedMessage = customAlarmMessages.first { !$0.isEmpty } ?? "Alarm"
            let selectedVoiceName = customVoiceNames[selectedVoiceForMessage]
            
            // Save the configuration back to the main alarm sheet view
            configuredMessage = selectedMessage
            configuredVoiceName = selectedVoiceName
            
            print("🎤 Voice and message settings configured:")
            print("📝 Message: \(selectedMessage)")
            print("🎵 Voice: \(selectedVoiceName)")
            print("✅ Configuration saved to main alarm view")
            
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
                    .stroke(Color("NeonGreen"), lineWidth: 2)
                    .shadow(color: Color("NeonGreen").opacity(0.6), radius: 6, x: 0, y: 0)
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
                        .foregroundColor(Color("NeonGreen"))
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
                    .stroke(Color("NeonGreen"), lineWidth: 2)
                    .shadow(color: Color("NeonGreen").opacity(0.6), radius: 6, x: 0, y: 0)
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
                            .foregroundColor(Color("NeonGreen"))
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
                    .foregroundColor(Color("NeonGreen"))
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color("NeonGreen"))
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
                    .foregroundColor(Color("NeonGreen"))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color("NeonGreen").opacity(0.2) : Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color("NeonGreen") : Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
#Preview {
    ContentView()
} 
