//
//  SignInView.swift
//  MyApp
//
//  Created by admin on 21/09/2020.
//  Copyright © 2020 Signe. All rights reserved.
//

import SwiftUI

struct SignInView: View
{
    // Make sure that when the sign-in flow is finished the dialogue disappears for know
    @Environment(\.presentationMode) var presentationMode
    
    @State var coordinator: SignInWithAppleCoordinator?
    
    var body: some View
    {
        VStack
        {
            Text("Thanks for using MyApp. Please sign in here.")
            SignInWithAppleButton()
            .frame(width: 280, height: 45)
            // Listen to the tap event and then kick off the sign in flow
            .onTapGesture
            {
                self.coordinator = SignInWithAppleCoordinator()
                if let coordinator = self.coordinator
                {
                    coordinator.startSignInWithAppleFlow
                    {
                        // here is the callback, and when the callback fires, we want to print something to the user
                        print("You successfully signed in")
                        self.presentationMode.wrappedValue.dismiss() // dismiss this after the user has tapped on the button
                        
                    }
                }
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider
{
    static var previews: some View
    {
        SignInView()
    }
}
