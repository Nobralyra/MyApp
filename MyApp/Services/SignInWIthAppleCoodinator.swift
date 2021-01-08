//
//  SignInWIthAppleCoodinator.swift
//  MyApp
//
//  Created by admin on 21/09/2020.
//  Copyright © 2020 Signe. All rights reserved.
//

import Foundation
import CryptoKit
import AuthenticationServices
import Firebase


class SignInWithAppleCoordinator: NSObject, ASAuthorizationControllerPresentationContextProviding
{
    // The callback property to capute the callback
    private var onSignedIn: (() -> Void)?
    
    
    // Will be called, in order to figure out what's the windows that's going to present the sign in with Apple Flow
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Ask the UIApplication for all its windows, and take the first window.
        return UIApplication.shared.windows.first!
    }
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?

    // Kicks off the sign-in flow, and provide the callback so it can be called at the end of the flow.
    @available(iOS 13, *)
    func startSignInWithAppleFlow(onSignedIn: @escaping () -> Void) {
        self.onSignedIn = onSignedIn
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    // Computing the SHA for our nonce
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

// This is a extension for the SignInWithAppleCoordinator
@available(iOS 13.0, *)
extension SignInWithAppleCoordinator: ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return
      }
      // Initialize a Firebase credential.
      let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                idToken: idTokenString,
                                                rawNonce: nonce)
      // Instead of signing in, we want to link. The user goes through the SignInWithApple flow, get credentials, and we want to link those credentials with our existing anonymous user credentials
        // The current user is the anonymous user, and we link this user with the credentials that we've received from the SignInWithApple flow
        Auth.auth().currentUser?.link(with: credential, completion: {
            (authResult, error) in
            if let error = error,  (error as NSError).code == AuthErrorCode.credentialAlreadyInUse.rawValue
            {
                print("The user you are trying to sign in with is has aldrady been linked")
                if let updatedCredential = (error as NSError).userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? OAuthCredential
                {
                    print("Signing in using the updated credentials")
                    Auth.auth().signIn(with: updatedCredential)
                    {
                        (authResult, error) in
                        if let user = authResult?.user
                        {
                            // want to invoke a callback - a way of signaling to the caller that the flow has finished, and the caller can remove or dismiss the sign-in form, and go back to the main list view, because the user has now signed in successfully.
                            if let callback = self.onSignedIn
                            {
                                callback()
                            }
                        }
                    }
                }
            }
            else
            {
                // want to invoke a callback - a way of signaling to the caller that the flow has finished, and the caller can remove or dismiss the sign-in form, and go back to the main list view, because the user has now signed in successfully.
                if let callback = self.onSignedIn
                {
                    callback()
                }
            }
        })
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }

}


// This function with give a so-called nonce - it is a random string that we will use to send to the API to make sure that we were the ones who have sent this request. Helps to prevent request forgery.
// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
private func randomNonceString(length: Int = 32) -> String {
  precondition(length > 0)
  let charset: Array<Character> =
      Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
  var result = ""
  var remainingLength = length

  while remainingLength > 0 {
    let randoms: [UInt8] = (0 ..< 16).map { _ in
      var random: UInt8 = 0
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
      if errorCode != errSecSuccess {
        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
      }
      return random
    }

    randoms.forEach { random in
      if remainingLength == 0 {
        return
      }

      if random < charset.count {
        result.append(charset[Int(random)])
        remainingLength -= 1
      }
    }
  }

  return result
}
