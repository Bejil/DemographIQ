//
//  MB_Firebase.swift
//
//  Created by BLIN Michael on 07/03/2025.
//

import Firebase

public class MB_Firebase {
	
	public static let shared:MB_Firebase = .init()
	
	public func start() {
		
		FirebaseApp.configure()
	}
}
