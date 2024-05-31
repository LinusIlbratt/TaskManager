//
//  HireServiceView.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-31.
//

import SwiftUI

struct HireServiceView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var address = ""
    @State private var date = Date()
    @State private var serviceType = ""
    @State private var additionalNotes = ""
    @State private var showingConfirmation = false
    
    var body: some View {
        
        NavigationView {
            VStack(spacing: 20) {
                TextField("Name", text: $name)
                    .customTextFieldStyle()
                
                TextField("Email", text: $email)
                    .customTextFieldStyle()
                
                TextField("Address", text: $address)
                    .customTextFieldStyle()
                
                TextField("What type of service", text: $serviceType)
                    .customTextFieldStyle()
                
                TextField("Additional requests or comments", text: $additionalNotes, axis: .vertical)
                    .customTextFieldStyle()
                
                VStack {
                    Text("Select date and time")
                        .font(.caption)
                    DatePicker("Date and time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                }
                
                Button(action: {
                    // Handle the booking submission here
                    submitBooking()
                }) {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.5))
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black, lineWidth: 1)
                            }
                        )
                }
                .padding(.top, 20)
            }
            .padding()
            .background(Color(UIColor.white)) // Bakgrund för hela vyn
            .cornerRadius(10) // Rundade hörn för att matcha bilden
            .padding() // Yttre padding för att skapa en snygg marginal
            .navigationBarTitle("Book Service", displayMode: .inline)
            .alert(isPresented: $showingConfirmation) {
                Alert(
                    title: Text("Booking Confirmed!"),
                    message: Text("\nYour booking request has been sent to our cleaning service. You will receive a confirmation via email shortly.\n\nPlease check your email for more information and further instructions.\n\nIf you have any questions or need to modify your booking, please do not hesitate to contact us."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    func submitBooking() {
        // Implement the booking submission logic here
        print("Booking submitted")
        // Send booking details to the cleaning company
        
        // Show confirmation alert
        showingConfirmation = true
    }

}

extension View {
    func customTextFieldStyle() -> some View {
        self
            .padding()
            .background(Color.white)
            .cornerRadius(5.0)
            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 3, y: 3)
    }
}

struct HireServiceView_Previews: PreviewProvider {
    static var previews: some View {
        HireServiceView()
    }
}
