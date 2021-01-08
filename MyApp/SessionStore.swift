//
//  SessionStore.swift
//  MyApp
//
//  Created by admin on 14/09/2020.
//  Copyright © 2020 Signe. All rights reserved.
//

import SwiftUI
import Firebase
import Combine

class SessionStore: ObservableObject
{
    var didChange = PassthroughSubject<SessionStore, Never>()
    @Published var session: User? {didSet { self.didChange.send(self) }}
    var handle: AuthStateDidChangeListenerHandle?
    
    func listen ()
    {
        // Tjekker om authentication ændre sig ved brug af Firebase
        handle = Auth.auth().addStateDidChangeListener
        {
            (auth, user) in
            if let user = user
            {
                // Hvis der er en user, lav ny user model
                print("Got user: \(user)")
                self.session = User(uid: user.uid, email: user.email)
            }
            else
            {
                self.session = nil
            }
        }
    }
    
    func signUP(email: String, password: String, handler: @escaping AuthDataResultCallback)
    {
        Auth.auth().createUser(withEmail: email, password: password, completion: handler)
    }
}


