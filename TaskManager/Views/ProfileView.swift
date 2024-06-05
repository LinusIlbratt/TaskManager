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
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                TopBar()
                Spacer().frame(height: 20) // Adding space between TopBar and the rest of the view
                
                VStack(alignment: .leading, spacing: 20) {
                    ProfileHeaderView(userViewModel: userViewModel)
                    
                    Spacer()
                    
                    VStack(spacing: 10) { // Grouping "Create New Group" and "Hire Service"
                        ActionButton(title: "Create New Group", action: {
                            navigateToNewGroup = true
                        })
                        .navigationDestination(isPresented: $navigateToNewGroup) {
                            NewGroupView(signedIn: $signedIn, groupName: "", description: "")
                        }
                        
                        ActionButton(title: "Hire Service", action: {
                            navigateToHireService = true
                        })
                        .navigationDestination(isPresented: $navigateToHireService) {
                            HireServiceView()
                        }
                    }
                    
                    Spacer().frame(height: 40) // Adding space between grouped buttons and Logout button

                    LogoutButton(action: {
                        handleLogout()
                    })
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
                .onAppear {
                    userViewModel.fetchCurrentUser()
                    userViewModel.fetchCurrentUserTotalAmountOfFishesCollected()
                }
            }
        }
    }
    
    private func handleLogout() {
        do {
            try Auth.auth().signOut()
            signedIn = false
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
}

struct ProfileHeaderView: View {
    @ObservedObject var userViewModel: UserViewModel

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 5) {
                Text("\(userViewModel.currentUser?.displayName ?? "")")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                
                Text("Total Mörtar")
                    .foregroundColor(.gray)
                    .font(.system(size: 24))
                
                TotalAmountOfFishesCollectedView(totalAmountOfFishesCollected: userViewModel.totalAmountOfFishesCollected)
            }
            Spacer()
        }
        .padding(.top, 5)
    }
}

struct ActionButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
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
    }
}

struct LogoutButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Logout")
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)
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
