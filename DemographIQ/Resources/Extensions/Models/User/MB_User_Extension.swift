//
//  MB_User_Extension.swift
//
//  Created by BLIN Michael on 01/01/2026.
//

import Foundation
import FirebaseFirestore

extension MB_User {
    
    /// Niveau dérivé des points d’expérience (`points`) : chaque manche réussie (classic ou plus/moins) ajoute 1 point.
    public var level:Int {
        
        var level = 1
        var remaining = max(0, points)
        var requiredForNextLevel = 5
        
        while remaining >= requiredForNextLevel {
            
            remaining -= requiredForNextLevel
            level += 1
            requiredForNextLevel = Int(Double(requiredForNextLevel) * 1.5)
        }
        
        return level
    }

    /// Progression vers le niveau suivant (0.0 … 1.0), basée sur les mêmes paliers que `level`.
    public var levelProgress:Float {
        
        var remaining = max(0, points)
        var requiredForNextLevel = 5
        
        while remaining >= requiredForNextLevel {
            remaining -= requiredForNextLevel
            requiredForNextLevel = Int(Double(requiredForNextLevel) * 1.5)
        }
        
        guard requiredForNextLevel > 0 else { return 0 }
        let progress = Float(remaining) / Float(requiredForNextLevel)
        return min(1.0, max(0.0, progress))
    }
	
	public static var current:MB_User {
		
		if let data = UserDefaults.get(.currentUser) as? Data, let player = try? JSONDecoder().decode(MB_User.self, from: data) {
			
			return player
		}
		
		let player:MB_User = .init()
		player.save()
		return player
	}
	
	public func save() {
		
		if let data = try? JSONEncoder().encode(self) {
			
			UserDefaults.set(data, .currentUser)
		}
	}
    
    public func saveLeaderboard(_ completion: ((Error?) -> Void)? = nil) {
        
        do {
            
            try Firestore.firestore().collection("leaderboard").document(id.uuidString).setData(from: self, completion: completion)
        }
        catch {
            
            completion?(error)
        }
    }
    
    public static func getLeaderboard(_ completion: ((Error?, [MB_User]?) -> Void)?) {
        
        Firestore.firestore().collection("leaderboard").getDocuments { snapshot, error in
            
            Task { @MainActor in
                
                let users = snapshot?.documents.compactMap({ try? $0.data(as: MB_User.self) })
                completion?(error, users)
            }
        }
    }
}
