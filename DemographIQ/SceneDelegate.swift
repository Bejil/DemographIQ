//
//  SceneDelegate.swift
//  Template
//
//  Created by Michaël Blin on 25/03/2026.
//

import UIKit

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
            
            let currentUser:MB_User = .current
            if currentUser.name == nil || (currentUser.name ?? "").isEmpty {
                
                let alertController:MB_User_Name_Alert_ViewController = .init()
                alertController.backgroundView.isUserInteractionEnabled = false
                alertController.present()
            }
        }
        window?.rootViewController = viewController
        
        window?.makeKeyAndVisible()
        
        MB_Audio.shared.playMusic()
    }
}
