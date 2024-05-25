//
//  ContentView.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-15.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    
    @State var signedIn = false
    
    
    var body: some View {
        if (!signedIn) {
            SignInView(signedIn : $signedIn)
        } else {
            TabView {
                NavigationStack {
                    TaskListView()
                }
                .tabItem {
                    Label("List", systemImage: "list.dash")
                        .font(.title)
                        .padding()
                }
                
                NavigationStack {
                    TaskView()
                }
                .tabItem {
                    Label("Scheduele", systemImage: "pencil")
                        .font(.title)
                        .padding()
                }
                
                NavigationStack {
                    ProfileView(signedIn: $signedIn)
                }
                .tabItem {
                    Label("User", systemImage: "person.fill")
                        .font(.title)
                        .padding()
                }
            }
            
        }
    }
}

struct SignInView : View {
    @StateObject private var userViewModel = UserViewModel()
    @Binding var signedIn : Bool
    @State var userName = "" //andreas@example.com"
    @State var password = "" //123456"
    @State private var displayName = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showDisplayNameAlert : Bool = false
    
    var auth = Auth.auth()
    var body : some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.largeTitle)
                .bold()
            
            
            TextField("Email", text: $userName)
                .keyboardType(.emailAddress)
                .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            HStack{
                Button(action: {
                    if userName.isEmpty {
                        alertMessage = "You missed fill in your email, try again"
                        showAlert = true
                    } else if password.isEmpty {
                        alertMessage = "You missed fill in your password, try again"
                        showAlert = true
                    } else {
                        if userViewModel.isValidEmail(email: userName) {
                            showDisplayNameAlert = true
                        } else {
                            alertMessage = "Your email seems not to be correct, please check and try again"
                            showAlert = true
                        }
                    }
                
                    
                }, label: {
                    Text("Sign up")
                
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .background(Color.blue)
                .cornerRadius(10)
                })
                .padding(.horizontal)
                
                
                Button(action: {
                    
                    
                    userViewModel.loginUser(email: userName, password: password) {
                        success in
                        if success {
                            print("USer loggedin ")
                            signedIn = true
                        } else {
                            
                            alertMessage = "failed to login"
                            showAlert = true
                        }
                    }
                }, label: {
                    Text("Log in")
                
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .background(Color.blue)
                .cornerRadius(10)
                })
                .padding(.horizontal)
                
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("An error occured"), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
        }
        .overlay() {
            ZStack {
                if showDisplayNameAlert {
                    DisplayNameView(isPresented: $showDisplayNameAlert, displayName: $displayName, showAlert: $showAlert, alertMessage: $alertMessage) {
                        registerUser()
                    }
                }
            }
        }
    }
    
    func registerUser() {
        userViewModel.createUser(email: userName, password: password, displayName: displayName) { success in
            if success {
                print("User registered correct")
                signedIn = true
            } else {
                alertMessage = "Failed to register"
                showAlert = true
            }
        }
    }
    
    struct DisplayNameView: View {
        @Binding var isPresented: Bool
        @Binding var displayName: String
        @Binding var showAlert: Bool
        @Binding var alertMessage : String
        var onSave: () -> Void
        
        var body: some View {
            VStack(spacing: 20) {
                Text("Enter Your Name")
                    .font(.headline)
                    .padding()
                
                TextField("Name", text: $displayName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                HStack {
                    Button(action: {
                        displayName = ""
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        if displayName != "" {
                            displayName = ""
                            onSave()
                        }else {
                            alertMessage = "You missed fill in your name, try again"
                            showAlert = true
                        }
                    }) {
                        Text("Save")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 20)
            .frame(maxWidth: 300)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
    }
    
}
#Preview {
    ContentView()
}
