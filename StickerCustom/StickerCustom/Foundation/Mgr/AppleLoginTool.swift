//
//  AppleLoginTool.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2022/1/20.
//

import Foundation
import AuthenticationServices

class AppleLoginTool: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    static let shared = AppleLoginTool()

    private override init() {
        super.init()
    }

    func isUserValid(completion: ((Bool) -> Void)?) {
        guard let userIdentifier = UserConfigMgr.shared.getValue(of: .userIdentifier) as? String else {
            completion?(false)
            return
        }
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userIdentifier) { (credentialState, error) in
            // 注意这里不是主线程
            switch credentialState {
            case .authorized:
                // The Apple ID credential is valid.
                completion?(true)
            case .revoked, .notFound:
                // The Apple ID credential is either revoked or was not found.
                completion?(false)
            default:
                completion?(false)
            }
        }
    }

    func login() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    // MARK: ASAuthorizationControllerDelegate

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            UserConfigMgr.shared.saveValue(userIdentifier, to: .userIdentifier)
            NotificationCenter.default.post(name: .appleLoginSuccess, object: self, userInfo: ["userIdentifier": userIdentifier])
        case _ as ASPasswordCredential:
            // Sign in using an existing iCloud Keychain credential.
            break
        default:
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {

    }

    // MARK: ASAuthorizationControllerPresentationContextProviding

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
}
