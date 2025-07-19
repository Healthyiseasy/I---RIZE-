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
                        
                        Text("79%")
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
    @State private var alarmLabel = ""
    
    var body: some View {
        NavigationView {
            VStack {
                #if os(iOS)
                DatePicker("Alarm Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                #else
                DatePicker("Alarm Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                #endif
                
                TextField("Alarm Label", text: $alarmLabel)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Add Alarm") {
                    let newAlarm = Alarm(time: selectedTime, isEnabled: true, label: alarmLabel.isEmpty ? "Alarm" : alarmLabel, repeatDays: [])
                    alarms.append(newAlarm)
                    scheduleNotification(for: newAlarm)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.neonGreen)
                
                Spacer()
            }
            .navigationTitle("Set Alarm")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                #endif
            }
        }
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
    @State private var selectedSentence = ""
    @State private var selectedVoice = ""
    @State private var customSentences: [String] = ["", "", ""]
    
    let alarmSentences: [String] = []
    let voices: [String] = []
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Title
                Text("Set Alarm")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Alarm Time Section
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
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                        .padding()
                                )
                                .frame(height: 200)
                        }
                        
                        // Alarm Sentence Section
                        VStack(alignment: .leading, spacing: 15) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.neonGreen, lineWidth: 2)
                                        .shadow(color: .neonGreen.opacity(0.6), radius: 8, x: 0, y: 0)
                                )
                                .overlay(
                                    VStack(alignment: .leading, spacing: 15) {
                                        Text("Alarm Sentence")
                                            .font(.headline)
                                            .foregroundColor(.neonGreen)
                                            .padding(.leading, 5)
                                        
                                        VStack(spacing: 12) {
                                            // Selected sentence
                                            Button(action: {
                                                // Show sentence picker
                                            }) {
                                                HStack {
                                                    Text(selectedSentence.isEmpty ? "(Empty)" : selectedSentence)
                                                        .foregroundColor(.white)
                                                        .lineLimit(1)
                                                    Spacer()
                                                    Image(systemName: "chevron.down")
                                                        .foregroundColor(.neonGreen)
                                                }
                                                .padding()
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(10)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                )
                                            }
                                            
                                            // Custom sentences
                                            ForEach(0..<3, id: \.self) { index in
                                                HStack {
                                                    TextField("Custom message", text: $customSentences[index])
                                                        .foregroundColor(.white)
                                                        .textFieldStyle(PlainTextFieldStyle())
                                                    Spacer()
                                                }
                                                .padding()
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(10)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                )
                                            }
                                        }
                                    }
                                    .padding()
                                )
                                .frame(height: 200)
                        }
                        
                        // Voice Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Voice")
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
                                    HStack(spacing: 15) {
                                        ForEach(0..<4, id: \.self) { index in
                                            Button(action: {
                                                // Voice selection action
                                            }) {
                                                Text("(Empty)")
                                                    .foregroundColor(.white)
                                                    .fontWeight(.medium)
                                                    .frame(maxWidth: .infinity)
                                                    .frame(height: 40)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .fill(Color.gray.opacity(0.1))
                                                    )
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                    )
                                            }
                                        }
                                    }
                                    .padding()
                                )
                                .frame(height: 80)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        testVoice()
                    }) {
                        Text("Test Voice")
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
                    
                    HStack(spacing: 15) {
                        Button(action: {
                            saveAlarm()
                        }) {
                            Text("Save Alarm")
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
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Close")
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
    
    private func testVoice() {
        // Voice testing functionality - ready for future implementation
        let testMessage = selectedSentence.isEmpty ? "Test message" : selectedSentence
        let utterance = AVSpeechUtterance(string: testMessage)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    private func saveAlarm() {
        let alarmMessage = customSentences.first { !$0.isEmpty } ?? (selectedSentence.isEmpty ? "Alarm" : selectedSentence)
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

#Preview {
    ContentView()
} 