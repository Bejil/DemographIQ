//
//  SceneDelegate.swift
//  Template
//
//  Created by Michaël Blin on 25/03/2026.
//

import UIKit
import UserMessagingPlatform

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        MB_Firebase.shared.start()
        
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = Colors.Background.Application
        
        let viewController:MB_Splashscreen_ViewController = .init()
        viewController.completion = { [weak self] in
            
            self?.window?.rootViewController = MB_Home_ViewController()
            
            let parameters = RequestParameters()
            parameters.isTaggedForUnderAgeOfConsent = false
            
            ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { [weak self] _ in
                
                ConsentForm.load { [weak self] form, _ in
                    
                    if ConsentInformation.shared.consentStatus == .required {
                        
                        form?.present(from: UI.MainController) { [weak self] _ in
                            
                            if ConsentInformation.shared.consentStatus == .obtained {
                                
                                self?.presentUserNameAlert()
                            }
                        }
                    }
                    else if ConsentInformation.shared.consentStatus == .obtained {
                        
                        self?.presentUserNameAlert()
                    }
                }
            }
        }
        window?.rootViewController = viewController
        
        window?.makeKeyAndVisible()
        
        MB_Audio.shared.playMusic()
    }
    
    private func presentUserNameAlert() {
        
        NotificationCenter.post(.updateAds)
        
        MB_Ads.shared.presentAppOpening {
            
            let currentUser:MB_User = .current
            if currentUser.name == nil || (currentUser.name ?? "").isEmpty {
                
                let alertController:MB_User_Name_Alert_ViewController = .init()
                alertController.backgroundView.isUserInteractionEnabled = false
                alertController.present()
            }
        }
    }
}
