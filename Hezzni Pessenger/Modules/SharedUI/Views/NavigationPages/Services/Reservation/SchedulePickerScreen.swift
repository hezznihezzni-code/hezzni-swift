//
//  SchedulePickerScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/23/25.
//

import SwiftUI

struct SchedulePickerScreen: View {
    @Binding var showSchedulePicker: Bool
    @Binding var selectedDate: Date
    
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                Text("Select Pickup Time")
                    .font(Font.custom("Poppins", size: 18).weight(.semibold))
                    .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("Choose when you'd like your driver to arrive.")
                    .font(Font.custom("Poppins", size: 14))
                    .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                    .opacity(0.70)
                
                WheelUIDatePicker(selectedDate: $selectedDate)
                    .frame(height: 202)
                    .background(
                        Rectangle()
                          .foregroundColor(.clear)
                          .frame(width: 362, height: 202)
                          .background(.white)
                          .cornerRadius(16)
                          .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06).opacity(0.06), radius: 25, x: 0, y: 4)
                    )
                
                PrimaryButton(
                    text: "Confirm Pickup Time",
                    isEnabled: true,
                    isLoading: false,
                    action: {
                        withAnimation {
                            showSchedulePicker = false
                        }
                    }
                )
                .padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 16)
    }
    
    private var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d 'at' h:mm a"
        return formatter.string(from: selectedDate)
    }
    
    private func confirmSchedule() {
        print("Ride scheduled for: \(formattedDateTime)")
        // Add your confirmation logic here
    }
}

// Wheel Style UIDatePicker
struct WheelUIDatePicker: UIViewRepresentable {
    @Binding var selectedDate: Date
    
    func makeUIView(context: Context) -> UIDatePicker {
        let datePicker = UIDatePicker()
        
        // Configure for wheel style
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        
        // Set minimum date (at least 1 hour from now)
        datePicker.minimumDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        
        // Set current date
        datePicker.date = selectedDate
        
        // Customize appearance if needed
        datePicker.tintColor = .systemBlue
        
        // Add target for value changes
        datePicker.addTarget(context.coordinator,
                           action: #selector(Coordinator.dateChanged(_:)),
                           for: .valueChanged)
        
        return datePicker
    }
    
    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = selectedDate
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: WheelUIDatePicker
        
        init(_ parent: WheelUIDatePicker) {
            self.parent = parent
        }
        
        @objc func dateChanged(_ sender: UIDatePicker) {
            parent.selectedDate = sender.date
        }
    }
}

#Preview {
    SchedulePickerScreen(showSchedulePicker: .constant(false), selectedDate: .constant(Date()))
}
