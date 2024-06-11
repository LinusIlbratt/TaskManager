//
//  NewGroupView.swift
//  TaskManager
//
//  Created by Andreas Selguson on 2024-05-30.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct NewGroupView: View {
    @Binding var signedIn : Bool
    @State var groupName : String = ""
    @State var description : String = ""
    @State var group : Groups?
    @State private var groupMembers: [User] = []
    @State private var newMember: String = ""
    @State private var showUserList = false
    @State private var availbleUsers: [User] = []
    @State private var users : [User] = []
    @State private var selectedUser : User?
    @StateObject private var userViewModel = UserViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(group == nil ? "Group information" : "Edit group")
                .font(.title)
                .bold()
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            
            TextField("Group name", text: $groupName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
            
            TextField("Description", text: $description)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
            
            if group != nil {
                if showUserList {
                    
                    Text("Add members: ")
                        .font(.headline)
                        .padding(.top, 10)
                        .padding(.horizontal, 20)
                    
                    List(availbleUsers, id: \.id) { user in
                        HStack {
                            Text(user.displayName)
                            Spacer()
                            Button(action: {
                                selectedUser = user
                                addSelctedMember(user)
                                fetchNonGruopMembers()
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.green)
                            }
                            
                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(height: 300)
                    .padding(.horizontal, 20)
                    .onAppear {
                        fetchNonGruopMembers()
                    }
                } else {
                    
                    
                    Text("Members: ")
                        .font(.headline)
                        .padding(.top, 10)
                        .padding(.horizontal, 20)
                    
                    List (groupMembers, id: \.id) { member in
                        HStack {
                            Text(member.displayName)
                            Spacer()
                            Button(action : {
                                removeMember(member)
                                
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(height: 300)
                    .padding(.horizontal, 20)
                }
            }
            Spacer()
            HStack{
                Button(action: {
                    //Add group
                    if let group = group {
                        userViewModel.updateGroup(id: group.id ?? "", name: groupName, description: description) { error in
                            if let error = error {
                                print("error update group \(error)")
                            } else {
                                print("success updateing group")
                                groupName = ""
                                description = ""
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    } else {
                        userViewModel.addGroup(name: groupName, description: description)
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                    
                }) {
                    
                    if showUserList {
                        Text(group == nil ? "Add Group" : "Update Group")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    } else {
                        Text(group == nil ? "Add Group" : "Update Group")
                        
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                }
                if group != nil {
                    if showUserList {
                        Button(action: {
                            showUserList = false
                        }) {
                            Text("Remove Members")
                            
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    } else {
                        Button(action: {
                            showUserList = true
                            fetchNonGruopMembers()
                        }) {
                            Text("Add Members")
                            
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            Spacer()
            
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            
            
        }
        
        .onAppear {
            if let group = group {
                groupName = group.name
                description = group.description ?? ""
                getGroupMembers(group : group)
            }
        }
        .onChange(of: group) { _, newGroup in
            if let newGroup = newGroup {
                groupName = newGroup.name
                description = newGroup.description ?? ""
                getGroupMembers(group: newGroup)
            }
        }
    }
    
    
    private func fetchNonGruopMembers() {
        userViewModel.fetchAllUsers { users in
            let newUsers = users.filter { user in
                !groupMembers.contains { $0.id == user.id }
            }
            self.availbleUsers = newUsers
            self.showUserList = true
            
        }
    }
    
    private func addSelctedMember(_ member: User) {
        userViewModel.addUserTo(groupID: group?.id ?? "", currentUserID: member.id!)
        if let index = availbleUsers.firstIndex(where: { $0.id != member.id }) {
            availbleUsers.remove(at: index)
        }
        groupMembers.append(member)
        
        
    }
    
    private func removeMember(_ member: User) {
        userViewModel.removeUserFrom(groupID: group?.id ?? "", currentUserID: member.id!) { error in
            if let error = error {
                // Handle error
                print("Error removing user from group: \(error)")
            } else {
                // Handle success
                print("User removed from group successfully")
                if let index = groupMembers.firstIndex(where: {$0.id == member.id}) {
                    groupMembers.remove(at: index)
                    showUserList = false
                    guard let group else {return}
                    getGroupMembers(group: group)
                }
            }
        }
        
        
    }
    
    private func getGroupMembers(group: Groups) {
        userViewModel.getGroupMembers(groupID: group.id ?? "") { members in
            groupMembers = members
        }
    }
}


struct NewGroupView_Previews: PreviewProvider {
    @State static var signedIn = false
    @State static var groupName = ""
    @State static var description = ""
    static var previews: some View {
        NewGroupView(signedIn: $signedIn, groupName: groupName, description: description, group: nil)
    }
}
