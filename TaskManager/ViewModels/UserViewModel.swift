//
//  UserViewModel.swift
//  TaskManager
//
//  Created by Andreas Selguson on 2024-05-25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import FirebaseAuth

@MainActor
class UserViewModel: ObservableObject {
    var auth = Auth.auth()
    private var db = Firestore.firestore()
    private var firestoreServices = FirebaseService()
    @Published var currentUser: User?
    @Published var totalAmountOfFishesCollected: Int? = nil
    
    func addGroup(name : String, description : String) {
        let group = Groups(name: name, description: description)
        do {
            let groupRef = try db.collection("groups").addDocument(from: group)
            addUserTo(groupID: groupRef.documentID)
            
        } catch {
            print ("Error adding group: \(error)")
        }
    }
    
    func addUserTo(groupID: String, currentUserID : String? = nil){
        let userID = currentUserID ?? (auth.currentUser?.uid ?? "")
        
        guard !userID.isEmpty else {
            print("user missing/not logged in")
            return
        }
        
        
        let userRef = db.collection("users").document(userID)
        userRef.getDocument { document, error in
            if let error = error {
                print("error get user from firebase")
                return
            }
            
            guard let document = document, document.exists else {
                print("user is missing")
                return
            }
            
            var userData = document.data() ?? [:]
            
            if var userGroups = userData["groups"] as? [String] {
                if !userGroups.contains(groupID) {
                    userGroups.append(groupID)
                    userData["groups"] = userGroups
                    userRef.setData(userData) { error in
                        if let error = error {
                            print("errpr adding group")
                        } else {
                            print("group added")
                        }
                    }
                } else {
                    print("user already in group")
                }
            } else {
                userData["groups"] = [groupID]
                userRef.setData(userData) { error in
                    if let error = error {
                        print("error updating user with group")
                    } else {
                        print("group added to user")
                    }
                }
            }

        }
    }
    
    func addUser(user : User) {
        do {
            _ = try db.collection("users").document(user.id ?? UUID().uuidString).setData(from: user)
        } catch {
            print ("Error adding user: \(error)")
        }
    }
    
    func createUser(email: String, password: String, displayName : String, completion: @escaping (Bool) -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("error logging in \(error)")
                completion(false)
            } else if let result = result {
                
                self.addUser(user: (User(id: result.user.uid, email: email, displayName: displayName,  totalAmountOfFishesCollected: 0)))
                completion(true)
                
            } else {
                completion(false)
            }
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("error logging in \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func isValidEmail(email : String) -> Bool {
            let regex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
            return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
        }
    
    func sendPasswordReset(email: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func fetchCurrentUser() {
            guard let userId = auth.currentUser?.uid else {
                print("No logged in user")
                return
            }
            
            let userRef = db.collection("users").document(userId)
            userRef.getDocument { document, error in
                if let error = error {
                    print("Error getting user: \(error)")
                    return
                }
                
                if let document = document, document.exists {
                    do {
                        self.currentUser = try document.data(as: User.self)
                    } catch {
                        print("Error decoding user: \(error)")
                    }
                } else {
                    print("User does not exist")
                }
            }
        }
    
    func fetchCurrentUserTotalAmountOfFishesCollected() {
            guard let userId = auth.currentUser?.uid else {
                print("No logged in user")
                return
            }

            let userRef = db.collection("users").document(userId)
            userRef.getDocument { document, error in
                if let error = error {
                    print("Error getting user: \(error)")
                    return
                }

                if let document = document, document.exists {
                    if let totalAmountOfFishesCollected = document.data()?["totalAmountOfFishesCollected"] as? Int {
                        DispatchQueue.main.async {
                            self.totalAmountOfFishesCollected = totalAmountOfFishesCollected
                        }
                    } else {
                        print("Total amount of fishes collected not found")
                    }
                } else {
                    print("User does not exist")
                }
            }
        }

}
