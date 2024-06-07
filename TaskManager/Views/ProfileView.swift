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
    @State private var groups : [Groups] = []
    @State private var selectedGroup : Groups?
    @State private var groupMembersNames : [String: String] = [:]
    @StateObject private var userViewModel = UserViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                TopBar()
                Spacer().frame(height: 20) // Adding space between TopBar and the rest of the view
                
                VStack(alignment: .leading, spacing: 20) {
                    ProfileHeaderView(userViewModel: userViewModel)
                    ScrollView {
                        //LazyVStack instead of List to allow for scrollview
                        LazyVStack {
                            ForEach(groups) { group in
                                Button(action: {
                                    selectedGroup = group
                                    navigateToNewGroup = true
                                }) {
                                    GroupRow(group : group, members : groupMembersNames[group.id ?? ""] ?? "")
                                        .onAppear {
                                            fetchMembers(for: group)
                                        }
                                }
                            }
                        }
                    }
                    .frame(height: 250)
                    .onAppear {
                        fetchGroups()
                    }
                    Spacer()
                    
                    VStack(spacing: 10) { // Grouping "Create New Group" and "Hire Service"
                        ActionButton(title: "Create New Group", action: {
                            selectedGroup = nil
                            navigateToNewGroup = true
                        })
                        .navigationDestination(isPresented: $navigateToNewGroup) {
                            NewGroupView(signedIn: $signedIn, groupName: "", description: "", group: selectedGroup)
                        }
                        
                        ActionButton(title: "Hire Service", action: {
                            navigateToHireService = true
                        })
                        .navigationDestination(isPresented: $navigateToHireService) {
                            HireServiceView()
                        }
                    }
                    
                    //Spacer().frame(height: 40) // Adding space between grouped buttons and Logout button

                    LogoutButton(action: {
                        handleLogout()
                    })
                    .padding(.bottom, 25)
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
    
    private func fetchGroups() {
        userViewModel.getMyGroups { fetchedGroups in
            groups = fetchedGroups
        }
    }
    private func fetchMembers(for group : Groups) {
        userViewModel.getGroupMembers(groupID: group.id ?? "") { members in
            let memberNames = members.map { $0.displayName }.joined(separator: ", ")
            groupMembersNames[group.id ?? ""] = memberNames
        }
    }
}
struct GroupRow: View {
    let group: Groups
    let members : String
    
    var body: some View {
        VStack(alignment: .leading) {
            if let description = group.description {
                Text(description)
                  .font(.subheadline)
                  .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
            }
            Text(group.name)
                .font(.headline)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
            Text(members)
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
        }
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
