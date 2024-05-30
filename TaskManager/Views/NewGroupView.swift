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
@State var groupName : String
@State var description : String
@StateObject private var userViewModel = UserViewModel()
@Environment(\.dismiss) var dismiss

var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Group information")
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
            
            
            Button(action: {
                //Add group
                if !groupName.isEmpty {
                    userViewModel.addGroup(name:  groupName, description: description)
                    dismiss()
                }
                
            }) {
                Text("Add Group")
                
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 135)
                
            }
            Spacer()
            
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}


struct NewGroupView_Previews: PreviewProvider {
    @State static var signedIn = false
    @State static var groupName = ""
    @State static var description = ""
    static var previews: some View {
        NewGroupView(signedIn: $signedIn, groupName: groupName, description: description)
    }
}
