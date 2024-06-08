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
    
    
    init() {
        TabViewAppearance.setupAppearance()
       }
        
        var body: some View {
            if (!signedIn) {
                SignInView(signedIn: $signedIn)
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
    @State private var alertMessage : String = ""
    @State private var alertTitle : String = ""
    @State private var showDisplayNameAlert : Bool = false
    @State private var showForgotPasswordButton: Bool = false
    @State private var userColor = Color.red
    
    var auth = Auth.auth()
    var body : some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Log in")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 20)
            
            Text("Email address")
                .padding(.horizontal, 20)
                .padding(.bottom, -10)
                
            TextField("Email", text: $userName)
                .keyboardType(.emailAddress)
                .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
            
            Text("Password")
                .padding(.horizontal, 20)
                .padding(.bottom, -10)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
            HStack{
                Button(action: {
                    if userName.isEmpty {
                        alertTitle = "An error occured"
                        alertMessage = "You missed fill in your email, try again"
                        showAlert = true
                    } else if password.isEmpty {
                        alertTitle = "An error occured"
                        alertMessage = "You missed fill in your password, try again"
                        showAlert = true
                    } else {
                        if userViewModel.isValidEmail(email: userName) {
                            showDisplayNameAlert = true
                        } else {
                            alertTitle = "An error occured"
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
                .background(Color.black)
                .cornerRadius(10)
                })
                .padding(.horizontal)
                
                
                Button(action: {
	                    if userName.isEmpty {
                        alertTitle = "An error occured"
                        alertMessage = "You missed fill in your email, try again"
                        showAlert = true
                    } else if password.isEmpty {
                        alertTitle = "An error occured"
                        alertMessage = "You missed fill in your password, try again"
                        showAlert = true
                    } else {
                        if userViewModel.isValidEmail(email: userName) {
                            userViewModel.loginUser(email: userName, password: password) {
                                success in
                                if success {
                                    print("USer loggedin ")
                                    signedIn = true
                                } else {
                                    alertTitle = "An error occured"
                                    alertMessage = "failed to login"
                                    showForgotPasswordButton = true
                                    showAlert = true
                                }
                            }
                        } else {
                            alertTitle = "An error occured"
                            alertMessage = "Your email seems not to be correct, please check and try again"
                            showAlert = true
                        }
                    }
                    
                    
                }, label: {
                    Text("Log in")
                
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .background(Color.black)
                .cornerRadius(10)
                })
                .padding(.horizontal)
                
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            if showForgotPasswordButton {
                return Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    primaryButton: .default(Text("Ok")),
                    secondaryButton: .default(Text("Forgot your password?")) {
                        userViewModel.sendPasswordReset(email: userName) {
                            success in
                            if success {
                                alertTitle = "Success"
                                alertMessage = "Check your inbox!"
                                showAlert = true
                            } else {
                                alertTitle = "An error occured"
                                alertMessage = "Something went wrong, check your emailaddress"
                                showAlert = true
                            }
                            
                            showForgotPasswordButton = false
                        }
                    }
                )
            } else {
                return Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("Ok"))
                )
            }
        }
        .overlay() {
            ZStack {
                if showDisplayNameAlert {
                    DisplayNameView(isPresented: $showDisplayNameAlert, displayName: $displayName, showAlert: $showAlert, alertMessage: $alertMessage, alertTitle: $alertTitle, userColor: $userColor) {
                        registerUser()
                    }
                }
            }
        }
    }
    
    func registerUser() {
        userViewModel.createUser(email: userName, password: password, displayName: displayName, userColor: userColor) { success in
            if success {
                print("User registered correct")
                signedIn = true
            } else {
                alertTitle = "An error occured"
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
        @Binding var alertTitle : String
        @Binding var userColor : Color
        var onSave: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("Create account")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)
                    
                Text("Your name")
                    .padding(.horizontal, 20)
                    .padding(.bottom, -10)
                
                TextField("Name", text: $displayName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                
                ColorPicker("Select a color", selection: $userColor)
                
                HStack {
                    Button(action: {
                        displayName = ""
                        isPresented = false
                    }, label: {
                        Text("Back")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(10)
                            .font(.headline)
                    })
                    .padding(.horizontal)
                    
                    Button(action: {
                        if !displayName.isEmpty {
                            onSave()
                        }else {
                            alertTitle = "An error occured"
                            alertMessage = "You missed fill in your name, try again"
                            showAlert = true
                        }
                    }, label: {
                        Text("Log in")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(10)
                            .font(.headline)
                      
                    })
                    .padding(.horizontal)
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
    ProfileView(signedIn: .constant(true))
}
