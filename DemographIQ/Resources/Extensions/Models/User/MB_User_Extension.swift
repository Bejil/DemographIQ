//
//  MB_User_Extension.swift
//
//  Created by BLIN Michael on 01/01/2026.
//

import Foundation

extension MB_User {
	
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
}
