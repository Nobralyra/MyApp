//
//  SignInWithAppleButton.swift
//  MyApp
//
//  Created by admin on 21/09/2020.
//  Copyright © 2020 Signe. All rights reserved.
//

import Foundation
import SwiftUI
import AuthenticationServices

// Use UIViewRepresentable to rep UIKit components and make them available to SwiftUI
struct SignInWithAppleButton: UIViewRepresentable
{
    // Create the button
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton
    {
        // type = silent button
        return ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    }
    
    // In case you want to propagate any property changes back into underlying class itself
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context)
    {
        
    }
}
