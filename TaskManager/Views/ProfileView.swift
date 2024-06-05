//
//  ProfileView.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-21.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @Binding var signedIn: Bool
    @State private var navigateToNewGroup = false
    @State private var navigateToHireService = false
    @StateObject private var userViewModel = UserViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Display the user's displayName
            HStack {
                Spacer()
                VStack {
                    Text("\(userViewModel.currentUser?.displayName ?? "")")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.top, 5)
                    
                    Text("Total Mörtar")
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                        .font(.system(size: 24))
                              
                    TotalAmountOfFishesCollectedView(totalAmountOfFishesCollected: userViewModel.totalAmountOfFishesCollected)
                }
                Spacer()
            }
            
            
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
                navigateToHireService = true
            }, label: {
                Text("Hire Service")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.clear)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
            })
            .navigationDestination(isPresented: $navigateToHireService) {
                HireServiceView()
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
        .onAppear {
            userViewModel.fetchCurrentUser()
            userViewModel.fetchCurrentUserTotalAmountOfFishesCollected()
        }
    }
}

struct TotalAmountOfFishesCollectedView: View {
    var totalAmountOfFishesCollected: Int?

    var body: some View {
        Group {
            if let totalAmountOfFishesCollected = totalAmountOfFishesCollected {
                Text("\(totalAmountOfFishesCollected)")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.gray)
                    
            } else {
                Text("Loading...")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.gray)
            }
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    @State static var signedIn = false
    
    static var previews: some View {
        ProfileView(signedIn: $signedIn)
    }
}
