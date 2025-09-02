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
            SimplifiedAlarmView(alarms: $alarms, onRemoveNotification: removeNotification)
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
            VStack(spacing: 2) {
                Text("POWERED BY")
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(Color("NeonGreen"))
                Text("IMPROVEMENT-MOVEMENT.COM")
                    .font(.system(size: 20, weight: .medium, design: .monospaced))
                    .foregroundColor(Color("NeonGreen"))
            }
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
    static let apiKey = "sk_f60744c13982e99133716fd1b5e759b22c3226bdf15c8eae"
    static let baseURL = "https://api.elevenlabs.io/v1"
    static let textToSpeechEndpoint = "/text-to-speech"
    
    // MARK: - Voice ID Configuration
    // ⚠️ IMPORTANT: Replace these with your actual ElevenLabs Voice IDs
    // Get them from: https://elevenlabs.io/ → Voice Library → Copy Voice ID
    static let simeonVoiceID = "alMSnmMfBQWEfTP8MRcX"  // Replace with actual Simeon voice ID
    static let rachelVoiceID = "21m00Tcm4TlvDq8ikWAM"// Replace with actual Rachel voice ID
    static let domiVoiceID = "AZnzlk1XvdvUeBnXmlld"      // Replace with actual Domi voice ID
    static let mrRubioVoiceID = "ZVpL7Q81HSRxP5LF40O5" // Replace with Mr. Rubio voice ID
    
    // Voice IDs for different character voices
    static let voiceIDs = [
        "Simeon": simeonVoiceID,
        "Rachel": rachelVoiceID,
        "Domi": domiVoiceID,
        "Mr. Rubio": mrRubioVoiceID
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
        print("🔍 DEBUG: ===== STARTING SPEECH GENERATION =====")
        print("🔍 DEBUG: FULL TEXT: '\(text)'")
        print("🔍 DEBUG: Text length: \(text.count) characters")
        print("🔍 DEBUG: Voice name: \(voiceName)")
        
        // ElevenLabs can handle longer text, but we need to ensure proper streaming
        // Just send the full text and let ElevenLabs handle it with proper timeouts
        print("🔍 DEBUG: Sending full text to ElevenLabs...")
        generateSpeechForChunk(text, voiceName: voiceName, completion: completion)
    }
    
    private func handleResponse(data: Data?, response: URLResponse?, error: Error?, voiceID: String, completion: @escaping (Data?) -> Void) {
        if let error = error {
            print("🔍 DEBUG: ElevenLabs API Error: \(error)")
            completion(nil)
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("🔍 DEBUG: Invalid response type")
            completion(nil)
            return
        }
        
        print("🔍 DEBUG: HTTP Status Code: \(httpResponse.statusCode)")
        print("🔍 DEBUG: Response Headers: \(httpResponse.allHeaderFields)")
        
        if let data = data {
            print("🔍 DEBUG: Response data size: \(data.count) bytes")
            // Check if this is actually audio data or an error message
            if data.count < 1000 {
                // Small response, might be an error message
                if let responseString = String(data: data, encoding: .utf8) {
                    print("🔍 DEBUG: Response body (likely error): \(responseString)")
                }
            } else {
                print("🔍 DEBUG: Large response - likely audio data")
            }
        }
        
        switch httpResponse.statusCode {
        case 200:
            print("✅ Success - Audio data received: \(data?.count ?? 0) bytes")
            if let data = data, data.count > 1000 {
                print("✅ Audio data looks valid")
                completion(data)
            } else {
                print("❌ Audio data too small, might be truncated")
                completion(nil)
            }
        case 401:
            print("❌ Unauthorized - Check your API key!")
            completion(nil)
        case 404:
            print("❌ Voice not found - Check voice ID: \(voiceID)")
            completion(nil)
        case 400:
            print("❌ Bad Request - Check your request format")
            completion(nil)
        case 413:
            print("❌ Payload Too Large - Text is too long for ElevenLabs")
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
    
    // MARK: - Text Chunking for Long Text
    
    private func splitTextIntoSmallChunks(_ text: String, maxSize: Int = 800) -> [String] {
        print("🔍 DEBUG: Splitting text into small chunks (max size: \(maxSize))")
        
        // Simple word-based splitting that guarantees small chunks
        let words = text.components(separatedBy: " ")
        var chunks: [String] = []
        var currentChunk = ""
        
        for word in words {
            let wordWithSpace = currentChunk.isEmpty ? word : " " + word
            
            // If adding this word would exceed the limit, save current chunk and start new one
            if currentChunk.count + wordWithSpace.count > maxSize {
                if !currentChunk.isEmpty {
                    chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
                    print("🔍 DEBUG: Created chunk: '\(currentChunk.prefix(50))...' (length: \(currentChunk.count))")
                }
                currentChunk = word
            } else {
                currentChunk += wordWithSpace
            }
        }
        
        // Add the last chunk if it's not empty
        if !currentChunk.isEmpty {
            chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
            print("🔍 DEBUG: Created final chunk: '\(currentChunk.prefix(50))...' (length: \(currentChunk.count))")
        }
        
        print("🔍 DEBUG: Total chunks created: \(chunks.count)")
        return chunks.isEmpty ? [text] : chunks
    }
    
    private func processMultipleChunks(_ chunks: [String], voiceName: String, completion: @escaping (Data?) -> Void) {
        print("🔍 DEBUG: ===== PROCESSING MULTIPLE CHUNKS =====")
        print("🔍 DEBUG: Processing \(chunks.count) chunks sequentially")
        
        var currentIndex = 0
        var allAudioData: [Data] = []
        
        func processNextChunk() {
            guard currentIndex < chunks.count else {
                // All chunks processed, combine and return
                print("🔍 DEBUG: All chunks processed successfully")
                if !allAudioData.isEmpty {
                    let combinedAudio = self.combineAudioChunks(allAudioData)
                    print("🔍 DEBUG: Combined audio size: \(combinedAudio.count) bytes")
                    completion(combinedAudio)
                } else {
                    print("🔍 DEBUG: No audio data to combine")
                    completion(nil)
                }
                return
            }
            
            let chunk = chunks[currentIndex]
            print("🔍 DEBUG: Processing chunk \(currentIndex + 1)/\(chunks.count): '\(chunk)'")
            
            generateSpeechForChunk(chunk, voiceName: voiceName) { audioData in
                if let audioData = audioData {
                    allAudioData.append(audioData)
                    print("🔍 DEBUG: Chunk \(currentIndex + 1) processed successfully: \(audioData.count) bytes")
                } else {
                    print("🔍 DEBUG: Chunk \(currentIndex + 1) failed to process")
                }
                
                currentIndex += 1
                // Process next chunk
                processNextChunk()
            }
        }
        
        // Start processing
        processNextChunk()
    }
    
    private func generateSpeechForChunk(_ text: String, voiceName: String, completion: @escaping (Data?) -> Void) {
        // Get the voice ID from the voice name
        guard let voiceID = ElevenLabsConfig.voiceIDs[voiceName] else {
            print("❌ Voice not found: \(voiceName)")
            completion(nil)
            return
        }
        
        let fullURL = "\(ElevenLabsConfig.baseURL)\(ElevenLabsConfig.textToSpeechEndpoint)/\(voiceID)/stream"
        print("🔍 DEBUG: Processing chunk: '\(text.prefix(50))...'")
        print("🔍 DEBUG: Full URL being called: \(fullURL)")
        print("🔍 DEBUG: API Key being used: \(ElevenLabsConfig.apiKey)")
        print("🔍 DEBUG: Voice ID: \(voiceID)")
        
        guard let url = URL(string: fullURL) else {
            print("Invalid URL for voice ID: \(voiceID)")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(ElevenLabsConfig.apiKey, forHTTPHeaderField: "xi-api-key")
        
        // Add timeout to prevent premature cutoff
        request.timeoutInterval = 60.0 // 60 seconds timeout
        
        let voiceSettings = getVoiceSettings(for: voiceName)
        let requestBody: [String: Any] = [
            "text": text,
            "model_id": "eleven_turbo_v2",
            "voice_settings": voiceSettings
        ]
        
        print("🔍 DEBUG: Request body being sent: \(requestBody)")
        print("🔍 DEBUG: Text being sent: '\(text)'")
        print("🔍 DEBUG: Text length: \(text.count) characters")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            print("🔍 DEBUG: Request body serialized successfully")
        } catch {
            print("🔍 DEBUG: Error creating request body: \(error)")
            completion(nil)
            return
        }
        
        // Use URLSession with proper configuration for streaming
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60.0
        config.timeoutIntervalForResource = 120.0
        config.waitsForConnectivity = true
        
        let session = URLSession(configuration: config)
        
        session.dataTask(with: request) { data, response, error in
            self.handleResponse(data: data, response: response, error: error, voiceID: voiceID, completion: completion)
        }.resume()
    }
    
    private func combineAudioChunks(_ chunks: [Data]) -> Data {
        print("🔍 DEBUG: Combining \(chunks.count) audio chunks")
        
        // For ElevenLabs audio, we can concatenate the raw data
        // Each chunk should be a complete audio segment
        var combinedData = Data()
        
        for (index, chunk) in chunks.enumerated() {
            print("🔍 DEBUG: Adding chunk \(index + 1): \(chunk.count) bytes")
            combinedData.append(chunk)
        }
        
        print("🔍 DEBUG: Final combined audio size: \(combinedData.count) bytes")
        return combinedData
    }

}

// MARK: - Notification Handler
final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate, AVAudioPlayerDelegate {
    static let shared = NotificationHandler()
    private let elevenLabsService = ElevenLabsService.shared
    private var currentAudioPlayer: AVAudioPlayer?
    
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
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("🎵 Audio playback finished successfully: \(flag)")
        currentAudioPlayer = nil
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("❌ Audio decode error: \(error?.localizedDescription ?? "Unknown error")")
        currentAudioPlayer = nil
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        print("⚠️ Audio playback interrupted")
    }
    
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: AVAudioSession.InterruptionOptions) {
        print("✅ Audio playback interruption ended")
        if flags.contains(.shouldResume) {
            player.play()
        }
    }
    
    private func playAlarmVoice(_ audioData: Data) {
        do {
            print("🎵 Playing alarm voice...")
            print("🎵 Audio data size: \(audioData.count) bytes")
            
            #if os(iOS)
            try setupAudioSession()
            #endif
            
            // Create audio player with proper configuration
            let audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer.volume = 1.0
            audioPlayer.numberOfLoops = 0
            audioPlayer.enableRate = false
            audioPlayer.prepareToPlay()
            
            // Set delegate to monitor playback
            audioPlayer.delegate = self
            
            let success = audioPlayer.play()
            print("🎵 Alarm voice player started: \(success)")
            
            if success {
                print("✅ Alarm voice is now playing")
                print("🎵 Expected duration: \(audioPlayer.duration) seconds")
                
                // Store reference to prevent deallocation
                self.currentAudioPlayer = audioPlayer
                
                // Monitor playback with longer intervals
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if audioPlayer.isPlaying {
                        print("✅ Audio still playing after 2 seconds")
                    } else {
                        print("❌ Audio stopped playing after 2 seconds")
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    if audioPlayer.isPlaying {
                        print("✅ Audio still playing after 5 seconds")
                    } else {
                        print("❌ Audio stopped playing after 5 seconds")
                    }
                }
                
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
        
        // Use a more compatible audio session configuration
        try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        print("🔊 Audio session activated for alarm")
        print("🔊 Audio session category: \(audioSession.category)")
        print("🔊 Audio session mode: \(audioSession.mode)")
        
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
    let predefinedMessages: [String]
    @Binding var customVoiceNames: [String]
    @Binding var voiceMessageAssignments: [String: String]
    let onSaveAndReturn: () -> Void
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
                        let assignmentKey = "\(voiceName)_\(messageIndex)"
                        let isAssigned = voiceMessageAssignments[assignmentKey] != nil
                        let hasMessage = !predefinedMessages[messageIndex].isEmpty
                        let canAssign = hasMessage
                        
                        Button(action: {
                            assignMessageToVoice(messageIndex: messageIndex, voiceName: voiceName)
                        }) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isAssigned && canAssign ? Color("NeonGreen") : Color.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(canAssign ? Color("NeonGreen") : Color.gray, lineWidth: 1)
                                )
                                .overlay(
                                    Group {
                                        if isAssigned && canAssign {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.black)
                                                .font(.caption)
                                                .fontWeight(.bold)
                                        } else if canAssign {
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
                        .disabled(!canAssign)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 15) {
            // Set button to lock in assignments and return to alarm selection
            Button("Set") {
                print("🎤 Locking in voice-message assignments: \(voiceMessageAssignments)")
                onSaveAndReturn()
                dismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("NeonGreen"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("NeonGreen"), lineWidth: 2)
                    )
            )
            .foregroundColor(.black)
            .font(.system(size: 16, weight: .bold))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private func assignMessageToVoice(messageIndex: Int, voiceName: String) {
        let message = predefinedMessages[messageIndex]
        if !message.isEmpty {
            // Create a unique key for this voice-message combination
            let assignmentKey = "\(voiceName)_\(messageIndex)"
            
            // If this specific combination is already assigned, remove it
            if voiceMessageAssignments[assignmentKey] != nil {
                voiceMessageAssignments.removeValue(forKey: assignmentKey)
                print("🎤 Removed assignment: '\(voiceName)' no longer has message \(messageIndex + 1)")
            } else {
                // Assign this specific message to this voice
                voiceMessageAssignments[assignmentKey] = message
                print("🎤 Assigned message \(messageIndex + 1) to voice '\(voiceName)'")
            }
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
    @State private var selectedAlarmIndex: Int? = nil
    
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
                    configuredMessage: $configuredMessage,
                    selectedAlarmIndex: selectedAlarmIndex,
                    selectedTime: selectedTime
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
            
                            Text(isEditingMode ? "Editing existing alarm. Change the time, message, or voice as needed." : "Each alarm slot can only hold one alarm. Configure voice and message first, then set your alarm time. Tapping an occupied slot will edit the existing alarm.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 5)
            
            ForEach(0..<3, id: \.self) { index in
                Button(action: {
                    selectAlarmSlot(index)
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
            if isEditingMode {
                Button("Update Alarm") {
                    if let editingIndex = editingAlarmIndex {
                        createOrUpdateAlarm(for: editingIndex)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            } else if selectedAlarmIndex != nil && !configuredMessage.isEmpty {
                // Show Create Alarm button when configuration is complete
                Button("Create Alarm \(selectedAlarmIndex! + 1)") {
                    if let alarmIndex = selectedAlarmIndex {
                        createOrUpdateAlarm(for: alarmIndex)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .background(Color("NeonGreen"))
                .foregroundColor(.black)
            }
            
            Button(isEditingMode ? "Cancel Edit" : "Back") {
                // Reset editing mode if going back
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
    
    private func selectAlarmSlot(_ index: Int) {
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
        
        // For new alarms, go to voice and message configuration
        // Store the selected alarm index for later use
        selectedAlarmIndex = index
        showingConfiguration = true
        print("🔔 Opening voice and message configuration for new alarm \(index + 1)")
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
    
    // Receive the selected time from AlarmSheetView
    let selectedTime: Date
    // Predefined messages that never change
    private let predefinedMessages = [
        "Wake up! It's a new day and a new chance to take control. You've got breath in your lungs, strength in your body, and fire in your spirit. No more snoozing through your potential — get up and show life exactly who you are. You're built for progress, made for impact, and today is yours to dominate. Let's move. Let's rise. Let's win.",
        "Time to rise and shine! The world is waiting for your energy, your creativity, and your unique perspective. Every morning is a fresh opportunity to make a difference, to learn something new, and to become the best version of yourself. Don't let this moment slip away - embrace it with enthusiasm and determination.",
        "Good morning, champion! You have the power to transform your day through your thoughts, your actions, and your attitude. Remember why you started this journey and let that motivation fuel your every step. Today is your chance to prove to yourself and the world what you're truly capable of achieving.",
        "Rise up, warrior! The challenges ahead are opportunities in disguise. Your strength, your resilience, and your unwavering spirit will carry you through anything. Trust in your abilities, stay focused on your goals, and remember that every great achievement begins with the decision to try."
    ]
    
    // User's selected messages for each slot
    @State private var customAlarmMessages = ["", "", "", ""]
    @State private var customVoiceNames = ["Simeon", "Rachel", "Domi", "Mr. Rubio"]
    @State private var showingMessagePicker = false
    @State private var selectedMessageIndex = 0
    @State private var selectedVoiceForMessage = 0
    
    // New: Voice-Message assignment mapping
    @State private var voiceMessageAssignments: [String: String] = [:]
    @State private var showingQuickAssignSheet = false
    
    // Store the selected alarm index for this configuration
    let selectedAlarmIndex: Int?
    
    // Debug: Print voice configuration on init
    init(alarms: Binding<[Alarm]>, configuredVoiceName: Binding<String>, configuredMessage: Binding<String>, selectedAlarmIndex: Int?, selectedTime: Date) {
        self._alarms = alarms
        self._configuredVoiceName = configuredVoiceName
        self._configuredMessage = configuredMessage
        self.selectedAlarmIndex = selectedAlarmIndex
        self.selectedTime = selectedTime
        print("🎤 SetAlarmView initialized with voices: \(["Simeon", "Rachel", "Domi", "Mr. Rubio"])")
        print("🎤 Voice count: \(["Simeon", "Rachel", "Domi", "Mr. Rubio"].count)")
        print("🎤 Selected alarm index: \(selectedAlarmIndex ?? -1)")
    }
    

    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                titleView
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        quickAssignmentSection
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
        .sheet(isPresented: $showingQuickAssignSheet) {
            QuickAssignmentSheet(
                customAlarmMessages: $customAlarmMessages,
                predefinedMessages: predefinedMessages,
                customVoiceNames: $customVoiceNames,
                voiceMessageAssignments: $voiceMessageAssignments,
                onSaveAndReturn: {
                    // Save all settings and return to alarm selection
                    print("🎤 Saving all voice-message assignments and returning to alarm selection")
                    showingQuickAssignSheet = false
                }
            )
        }
        .onAppear {
            print("🎤 SetAlarmView appeared with voices: \(customVoiceNames)")
            print("🎤 Voice count: \(customVoiceNames.count)")
            print("🎤 Messages count: \(customAlarmMessages.count)")
            
            // No automatic assignments - interface starts clean
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
                    // Find all messages assigned to this voice
                    let assignedMessages = predefinedMessages.enumerated().compactMap { index, message in
                        let assignmentKey = "\(voiceName)_\(index)"
                        return voiceMessageAssignments[assignmentKey] != nil ? message : nil
                    }
                    
                    let assignedMessage = assignedMessages.isEmpty ? "No message assigned" : assignedMessages.joined(separator: ", ")
                    let hasAssignment = !assignedMessages.isEmpty
                    
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
                            Image(systemName: "plus.circle")
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
                    .onTapGesture {
                        // Allow tapping to see assignment details
                        print("🎤 Tapped on voice: \(voiceName)")
                        if hasAssignment {
                            print("🎤 Current assignments: \(assignedMessages)")
                        }
                    }
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
        // Check if user has selected any messages
        let hasSelectedMessage = customAlarmMessages.contains { !$0.isEmpty }
        
        if !hasSelectedMessage {
            print("⚠️ Please select at least one message before setting the voice and message")
            return
        }
        
        // Check if there are any voice assignments from QuickAssignmentSheet
        if !voiceMessageAssignments.isEmpty {
            // Use the first assigned voice and message
            for (assignmentKey, message) in voiceMessageAssignments {
                if !message.isEmpty {
                    // Extract voice name from assignment key (format: "VoiceName_MessageIndex")
                    let components = assignmentKey.split(separator: "_")
                    if components.count == 2, let voiceName = components.first {
                        configuredVoiceName = String(voiceName)
                        configuredMessage = message
                        print("🎤 Using assigned voice and message:")
                        print("📝 Message: \(message)")
                        print("🎵 Voice: \(configuredVoiceName)")
                        break
                    }
                }
            }
        } else {
            // No assignments - use the currently selected voice and first non-empty message
            if configuredVoiceName.isEmpty {
                configuredVoiceName = customVoiceNames[0] // Default to first voice
            }
            
            // Find first non-empty message
            if let firstMessage = customAlarmMessages.first(where: { !$0.isEmpty }) {
                configuredMessage = firstMessage
            }
            
            print("🎤 Using selected voice and message:")
            print("📝 Message: \(configuredMessage)")
            print("🎵 Voice: \(configuredVoiceName)")
        }
        
        print("✅ Configuration locked in for alarm slot \(selectedAlarmIndex.map { $0 + 1 } ?? 0)")
        print("📝 Locked Message: \(configuredMessage)")
        print("🎵 Locked Voice: \(configuredVoiceName)")
        
        // Don't create the alarm yet - just save the configuration and return
        // The user will create the alarm when they go back to the main interface
        dismiss()
    }
    
    private func createAlarmForIndex(_ index: Int) {
        // Create a new alarm with the configured voice, message, and selected time
        let newAlarm = Alarm(
            time: selectedTime, // Use the time selected in AlarmSheetView
            isEnabled: true,
            label: configuredMessage,
            repeatDays: [],
            voiceName: configuredVoiceName
        )
        
        alarms.append(newAlarm)
        
        // Schedule the notification
        scheduleNotification(for: newAlarm, voiceName: configuredVoiceName)
        
        print("🔔 Created new alarm \(index + 1): \(configuredMessage) with voice: \(configuredVoiceName) at time: \(selectedTime)")
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
            if let error = error {
                print("❌ Error scheduling notification: \(error)")
            } else {
                print("✅ Notification scheduled successfully for alarm: \(alarm.label)")
            }
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

// MARK: - Simplified Alarm View
struct SimplifiedAlarmView: View {
    @Binding var alarms: [Alarm]
    let onRemoveNotification: (Alarm) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTime = Date()
    @State private var selectedMessage = ""
    @State private var selectedVoice = "Simeon"
    @State private var showingMessagePicker = false
    @State private var showingVoicePicker = false
    
    // Predefined messages
    private let predefinedMessages = [
        "Wake up! It's a new day and a new chance to take control. You've got breath in your lungs, strength in your body, and fire in your spirit. No more snoozing through your potential — get up and show life exactly who you are. You're built for progress, made for impact, and today is yours to dominate. Let's move. Let's rise. Let's win.",
        "Time to rise and shine! The world is waiting for your energy, your creativity, and your unique perspective. Every morning is a fresh opportunity to make a difference, to learn something new, and to become the best version of yourself. Don't let this moment slip away - embrace it with enthusiasm and determination.",
        "Good morning, champion! You have the power to transform your day through your thoughts, your actions, and your attitude. Remember why you started this journey and let that motivation fuel your every step. Today is your chance to prove to yourself and the world what you're truly capable of achieving.",
        "Rise up, warrior! The challenges ahead are opportunities in disguise. Your strength, your resilience, and your unwavering spirit will carry you through anything. Trust in your abilities, stay focused on your goals, and remember that every great achievement begins with the decision to try."
    ]
    
    private let availableVoices = ["Simeon", "Rachel", "Domi", "Mr. Rubio"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    titleView
                    timePickerSection
                    messageSelectionSection
                    voiceSelectionSection
                    Spacer()
                    actionButtonsSection
                }
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .sheet(isPresented: $showingMessagePicker) {
                MessagePickerView(
                    selectedMessage: $selectedMessage,
                    predefinedMessages: predefinedMessages
                )
            }
            .sheet(isPresented: $showingVoicePicker) {
                VoicePickerView(
                    selectedVoice: $selectedVoice,
                    availableVoices: availableVoices
                )
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
    
    private var messageSelectionSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Alarm Message")
                .font(.headline)
                .foregroundColor(Color("NeonGreen"))
                .padding(.leading, 5)
            
            Button(action: {
                showingMessagePicker = true
            }) {
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
                                Text(selectedMessage.isEmpty ? "Choose Message" : "Message Selected")
                                    .foregroundColor(selectedMessage.isEmpty ? .gray : .white)
                                    .font(.system(size: 16, weight: .medium))
                                
                                if !selectedMessage.isEmpty {
                                    Text(selectedMessage.prefix(50) + (selectedMessage.count > 50 ? "..." : ""))
                                        .foregroundColor(Color("NeonGreen"))
                                        .font(.caption)
                                        .lineLimit(2)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color("NeonGreen"))
                        }
                        .padding()
                    )
                    .frame(height: selectedMessage.isEmpty ? 60 : 80)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
    }
    
    private var voiceSelectionSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Voice")
                .font(.headline)
                .foregroundColor(Color("NeonGreen"))
                .padding(.leading, 5)
            
            Button(action: {
                showingVoicePicker = true
            }) {
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
                                Text("Voice: \(selectedVoice)")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text(getVoiceDescription(selectedVoice))
                                    .foregroundColor(Color("NeonGreen"))
                                    .font(.caption)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color("NeonGreen"))
                        }
                        .padding()
                    )
                    .frame(height: 60)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 15) {
            Button("Create Alarm") {
                createAlarm()
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(selectedMessage.isEmpty)
            
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private func getVoiceDescription(_ voice: String) -> String {
        switch voice {
        case "Simeon": return "Friendly and approachable"
        case "Rachel": return "Warm and caring"
        case "Domi": return "Energetic and dynamic"
        case "Mr. Rubio": return "Professional and authoritative"
        default: return "Custom voice"
        }
    }
    
    private func createAlarm() {
        let newAlarm = Alarm(
            time: selectedTime,
            isEnabled: true,
            label: selectedMessage,
            repeatDays: [],
            voiceName: selectedVoice
        )
        
        alarms.append(newAlarm)
        scheduleNotification(for: newAlarm, voiceName: selectedVoice)
        
        print("🔔 Created new alarm: \(selectedMessage) with voice: \(selectedVoice)")
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
                }
            }
        }
    }
}

// MARK: - Voice Picker View
struct VoicePickerView: View {
    @Binding var selectedVoice: String
    let availableVoices: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Text("Choose Voice")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(availableVoices, id: \.self) { voice in
                                Button(action: {
                                    selectedVoice = voice
                                    dismiss()
                                }) {
                                    VoicePickerRow(
                                        voice: voice,
                                        isSelected: selectedVoice == voice
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

struct VoicePickerRow: View {
    let voice: String
    let isSelected: Bool
    
    private func getVoiceDescription(_ voice: String) -> String {
        switch voice {
        case "Simeon": return "Friendly and approachable"
        case "Rachel": return "Warm and caring"
        case "Domi": return "Energetic and dynamic"
        case "Mr. Rubio": return "Professional and authoritative"
        default: return "Custom voice"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(voice)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                
                Text(getVoiceDescription(voice))
                    .foregroundColor(Color("NeonGreen"))
                    .font(.caption)
            }
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
