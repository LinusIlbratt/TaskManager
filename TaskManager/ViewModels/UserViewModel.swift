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
                
                self.addUser(user: (User(id: result.user.uid, email: email, displayName: displayName)))
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
    
}
