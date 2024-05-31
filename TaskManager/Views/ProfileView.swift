//
//  ProfileView.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-21.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
@Binding var signedIn : Bool
@State private var navigateToNewGroup = false
    

var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Manage Groups")
                .font(.title)
                .bold()
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
                        
            //List groups you are member of
            
            
            Spacer()
            
            
            Button(action: {
                //Manage family
                navigateToNewGroup = true
            }) {
                Text("Create New Group")
                
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.clear)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
                
            }
            .navigationDestination(isPresented: $navigateToNewGroup) {
                NewGroupView(signedIn: $signedIn, groupName: "", description: "")
            }
                                      
            .padding(.horizontal, 20)
            
            Button(action: {
                do {
                    try Auth.auth().signOut()
                    signedIn = false
                } catch let signOutError as NSError {
                    print("Error signing out: \(signOutError)")
                }
            }) {
                Text("Logout")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.clear)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    @State static var signedIn = false

    static var previews: some View {
        ProfileView(signedIn: $signedIn)
    }
}
