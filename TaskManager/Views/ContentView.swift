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
    @Binding var signedIn : Bool
    @State var userName = "" //andreas@example.com"
    @State var password = "" //123456"
    
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
                    
                    auth.createUser(withEmail: userName, password: password) { result, error in
                        if let error = error {
                            print("error logging in \(error)")
                        } else {
                            signedIn = true
                        }
                    }
                }, label: {
                    Text("Sign up")
                })
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.horizontal)
                
                Button(action: {
                    
                    
                    auth.signIn(withEmail: userName, password: password) { result, error in
                        if let error = error {
                            print("error logging in \(error)")
                        } else {
                            signedIn = true
                        }
                    }
                }, label: {
                    Text("Log in")
                })
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.horizontal)
                
            }
        }
    }
}

#Preview {
    ContentView()
}
